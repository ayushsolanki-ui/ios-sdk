import Foundation
import StoreKit
import SwiftUI

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

@MainActor
class PaymentStore: ObservableObject {
    @AppStorage("subscribed") private var isSubscribed: Bool = false
    
    @Published var tabIndex: Int = 0
    @Published var isLoading = true
    @Published var isPurchaseInProgress: Bool = false
    
    @Published var showToast = false
    @Published var error: ErrorModel?
    
    @Published var serverProducts: [ServerProduct] = []
    @Published var vendorThemes: [ServerThemeModel]?
    @Published var activeUserDetails: ActiveUserResponse?
    
    @Published private(set) var storeProducts: [Product] = []
    @Published var selectedProduct: ServerProduct?
    @Published private(set) var purchasedSubscription: ServerProduct?
    
    var yearlyProducts: [ServerProduct] {
        return serverProducts.filter { $0.recurringPeriodCode.isYearly }
    }
    
    var monthlyProducts: [ServerProduct] {
        return serverProducts.filter { $0.recurringPeriodCode.isMonthly }
    }
    
    var weeklyProducts: [ServerProduct] {
        return serverProducts.filter { $0.recurringPeriodCode.isWeekly }
    }
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    var appService = AppService();
    var storekitService = StoreKitService();
    
    let userId: String
    let apiKey: String
    
    init(userId: String, apiKey: String) {
        self.userId = userId
        self.apiKey = apiKey
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    @MainActor
    func initPaymentPlatform() async {
        isLoading = true
        defer { isLoading = false }
        await fetchActiveUserDetails()
        await handleCachedTheme()
        await handleCachedProducts()
        await updateSubscriptionStatus()
    }

    func setAppService(_ appService: AppService) {
        self.appService = appService
    }
    func setStoreKitService(_ skService: StoreKitService) {
        self.storekitService = skService
    }
    
    // observable methods
    @MainActor
    func showToastForLimitedTime() {
        withAnimation {
            showToast = true
        }
        Task {
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            withAnimation {
                showToast = false
            }
            error = nil
        }
    }
    
    @MainActor
    func handleCachedTheme() async {
        if let themeTimestamp = activeUserDetails?.themConfigTimeStamp {
            if let theme = CacheManager.getCachedTheme(themeTimestamp) {
                vendorThemes = theme
            } else {
                let theme = await fetchAppTheme()
                CacheManager.saveThemeCache(ThemeCache(timeStamp: themeTimestamp, theme: theme))
                vendorThemes = theme
            }
            guard let vendorThemesData = vendorThemes else {
                return
            }
            ThemeManager.shared.updateTheme(with: vendorThemesData)
        }
    }
    
    @MainActor
    func handleCachedProducts() async {
        if let productsTimestamp = activeUserDetails?.productUpdateTimeStamp {
            if let products = CacheManager.getCachedProducts(productsTimestamp) {
                serverProducts = products
            } else {
                let products = await fetchServerProducts()
                CacheManager.saveProductsCache(SubscriptionProductsCache(timeStamp: productsTimestamp, products: products))
                serverProducts = products
            }
        }
    }
    
    @MainActor
    func handleTransaction(_ receipt: String, _ transaction: Transaction?) async {
        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }
        do {
            let resp = try await appService.sendVerifiedCheck(userId, apiKey, receipt, transaction)
            guard let sub = resp.data, resp.code == 200 else {
                setError(resp.title, resp.message)
                return
            }
            await MainActor.run {
                self.purchasedSubscription = self.serverProducts.first {
                    $0.id == sub.id
                }
                self.selectedProduct = nil
            }
        } catch {
            setError("Transaction Failed!", "Purchase Unsuccessful.")
        }
        if let transaction = transaction {
            await transaction.finish()
        }
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        guard let active = activeUserDetails,
              let subscribedProduct = active.subscriptionResponseDTO
        else {
            print("No Existing Subscriptions found!")
            return;
        }
        let purchasedSubcriptionId = subscribedProduct.id
        
        if let subscribedProduct = serverProducts.first(where: { $0.id ==  purchasedSubcriptionId}) {
            self.purchasedSubscription = subscribedProduct
        }
        else {
            serverProducts.append(subscribedProduct.product)
        }
        isSubscribed = true
    }
    
    func setError(_ title: String, _ description: String) {
        error = ErrorModel(title: "Error", message: description)
    }
    
    // StoreKit 2 calls
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            print("Starting transaction listener...")
            for await result in Transaction.updates {
                do {
                    let receipt = result.jwsRepresentation
                    let transaction: Transaction = try Helpers.checkVerified(result)
                    print("listenForTransactions started = \(transaction.productID)")
                    await self.handleTransaction(receipt, transaction)
                    await transaction.finish()
                } catch {
                    let errorMessage = error.localizedDescription
                    print("Error in listenForTransactions: \(errorMessage)")
                }
            }
        }
    }
    
    @MainActor
    func fetchStoreProducts(_ productIds: [String]) async -> [Product]? {
        if(productIds.isEmpty) {
            setError("Error", "No Products available.");
            return nil
        }
        
        do {
            let sk2Products = try await storekitService.fetchProductsFromAppStore(for: productIds)
            storeProducts = sk2Products
            return sk2Products
        } catch StoreError.noProductsInStore {
            let errMsg = "Got 0 products in App store."
            setError("Error", errMsg);
            return nil
        } catch {
            let errMsg = "Failed to fetch App Store products: \(error.localizedDescription)"
            setError("Error", errMsg);
            print("fetchStoreProducts - \(error)")
            return nil
        }
    }
    
    // API calls
    @MainActor
    func fetchAppTheme() async -> [ServerThemeModel] {
        do {
            let response = try await appService.getAppTheme(apiKey)
            guard let themes = response.data, response.code == 200 else {
                print("Theme Api Error");
                setError(response.title, response.message)
                return []
            }
            return themes
        } catch {
            print("App theme fetch failed: \(error.localizedDescription)")
            setError("Error", error.localizedDescription)
            return []
        }
    }
    
    @MainActor
    func fetchServerProducts() async -> [ServerProduct] {
        do {
            let response = try await appService.loadSubscriptionPlans(apiKey)
            guard let products = response.data, response.code == 200 else {
                setError(response.title, response.message)
                return []
            }
            return products
        } catch {
            let errorMessage = "Failed to fetch products: \(error.localizedDescription)"
            setError("Error", errorMessage);
            print("fetchServerProducts - \(error)")
            return []
        }
    }
    
    @MainActor
    func purchaseProduct(with serverProduct: ServerProduct) async {
        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }
        
        let purchasingProductId = serverProduct.id
        print("purchasingProductId id = \(purchasingProductId)")
        
        let purchasingStoreProduct: Product? = Helpers.getStoreProduct(with: purchasingProductId, from: storeProducts)
        var products: [Product]?
        if storeProducts.isEmpty || purchasingStoreProduct == nil  {
            products = await fetchStoreProducts([purchasingProductId])
        } else {
            products = [purchasingStoreProduct!]
        }
        
        guard let storeProducts = products,
              let storeProduct = Helpers.getStoreProduct(with: purchasingProductId, from: storeProducts) else {
            setError("Unavailable", "Product could not be found.");
            return
        }
        
        do {
            let result = try await storekitService.purchaseStoreProduct(storeProduct, userId)
            switch result {
            case .success(let verification):
                let receipt = verification.jwsRepresentation
                let transaction: Transaction = try Helpers.checkVerified(verification)
                await handleTransaction(receipt, transaction);
                print("Product purchase successfull: \(purchasingProductId)")
                await transaction.finish()
            case .userCancelled:
                print("User cancelled the purchase")
                // setError("Error", "Purchase Cancelled");
                
            case .pending:
                setError("Error", "Purchase is pending");
                
            default:
                setError("Error", "Unknown purchase result");
                
            }
        } catch {
            let errorMessage = "Purchase failed: \(error.localizedDescription)"
            setError("Error", errorMessage);
        }
        
    }
    
    @MainActor
    func fetchActiveUserDetails() async {
        do {
            let response = try await appService.getUserSubscriptionDetails(for: userId, with: apiKey)
            guard let details = response.data, response.code == 200 else {
                setError(response.title, response.message)
                return
            }
            self.activeUserDetails = details
        } catch {
            print("Error fetching user subscription details.")
            setError("Unknown Error", error.localizedDescription)
        }
    }
}
