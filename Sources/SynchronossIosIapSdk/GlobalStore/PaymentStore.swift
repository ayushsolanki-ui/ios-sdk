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
    
    var updateListenerTask: Task<Void, Never>? = nil
    
    let appService = AppService();
    let storekitService = StoreKitService();
    
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
        await fetchActiveUserDetails()
        await handleCachedTheme()
        await handleCachedProducts()
        await updateSubscriptionStatus()
        isLoading = false
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
    func handleTransaction(_ receipt: String, _ transaction: Transaction) async {
        isPurchaseInProgress = true
        do {
            let success = try await appService.sendVerifiedCheck(userId, apiKey, receipt, transaction)
            print("handleTransaction success = \(success)")
            if success {
                await MainActor.run {
                    self.purchasedSubscription = self.serverProducts.first {
                        $0.id == transaction.productID
                    }
                    self.selectedProduct = nil
                }
            } else {
                setError("Error", "Purchase Unsuccessful.");
            }
        } catch {
            setError("Transaction Failed!", "Purchase Unsuccessful.")
        }
        await transaction.finish()
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
            isSubscribed = true
        }
        else {
            isSubscribed = false
        }
    }
    
    func setError(_ title: String, _ description: String) {
        error = ErrorModel(title: "Error", message: description)
    }
    
    // StoreKit 2 calls
    func listenForTransactions() -> Task<Void, Never> {
        return Task { [weak self] in
            guard let self = self else { return }
            print("Starting transaction listener...")
            for await result in Transaction.updates {
                print("listenForTransactions started")
                do {
                    isPurchaseInProgress = true
//                    let receipt = result.jwsRepresentation
                    let transaction = try result.payloadValue
                    await transaction.finish()
//                    await handleTransaction(receipt, transaction)
                } catch {
                    let errorMessage = error.localizedDescription
                    setError("Error", errorMessage);
                    isPurchaseInProgress = false
                }
            }
        }
    }
    
    @MainActor
    func fetchStoreProducts(_ productIds: [String]) async {
        if(productIds.isEmpty) {
            setError("Error", "No Products available.");
            return
        }
        
        do {
            let sk2Products = try await storekitService.fetchProductsFromAppStore(for: productIds)
            storeProducts = sk2Products
        } catch StoreError.noProductsInStore {
            let errMsg = "Got 0 products in App store."
            setError("Error", errMsg);
        } catch {
            let errMsg = "Failed to fetch App Store products: \(error.localizedDescription)"
            setError("Error", errMsg);
            print("fetchStoreProducts - \(error)")
        }
    }
    
    // API calls
    @MainActor
    func fetchAppTheme() async -> [ServerThemeModel] {
        do {
            let response = try await appService.getAppTheme(apiKey)
            return response
        } catch {
            print("App theme fetch failed: \(error.localizedDescription)")
            return []
        }
    }
    
    @MainActor
    func fetchServerProducts() async -> [ServerProduct]{
        do {
            let products = try await appService.loadSubscriptionPlans(apiKey)
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
        
        let purchasingProductId = serverProduct.id
        print("purchasingProductId id = \(purchasingProductId)")
        
        let purchasingStoreProduct : Product? = Helpers.getStoreProduct(with: purchasingProductId, from: storeProducts)
        if storeProducts.isEmpty || purchasingStoreProduct == nil  {
            await fetchStoreProducts([purchasingProductId])
        }
        let storeProduct = Helpers.getStoreProduct(with: purchasingProductId, from: storeProducts)
        guard let product = storeProduct else {
            isPurchaseInProgress = false
            return
        }
        
        do {
            let result = try await storekitService.purchaseStoreProduct(product, userId)
            switch result {
            case .success(let verification):
                let receipt = verification.jwsRepresentation
                let transaction: Transaction = try Helpers.checkVerified(verification)
                await handleTransaction(receipt, transaction);
                print("Product purchase successfull: \(purchasingProductId)")
            case .userCancelled:
                print("User cancelled the purchase")
                // setError("Error", "Purchase Cancelled");
                
            case .pending:
                setError("Error", "Purchase is pending");
                
            default:
                setError("Error", "Unknown purchase result");
                
            }
            isPurchaseInProgress = false
        } catch {
            let errorMessage = "Purchase failed: \(error.localizedDescription)"
            setError("Error", errorMessage);
            isPurchaseInProgress = false
        }
        
    }
    
    @MainActor
    func fetchActiveUserDetails() async {
        do {
            let activeUser = try await appService.getUserSubscriptionDetails(for: userId, with: apiKey)
            self.activeUserDetails = activeUser
        } catch {
            print("Error fetching user subscription details.")
        }
    }
}
