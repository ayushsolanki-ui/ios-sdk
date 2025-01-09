import Foundation
import StoreKit
import SwiftUI

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

class PaymentStore: ObservableObject {
    @AppStorage("subscribed") private var isSubscribed: Bool = false
    
    @Published var tabIndex: Int = 0
    @Published var serverProducts: [ServerProduct] = []
    @Published var isLoading = true
    @Published var showToast = false
    @Published var error: ErrorModel?
    @Published var userSubscriptionDetails: [UserSubscriptionDetails] = []
    @Published var isPurchaseInProgress: Bool = false
    @Published private(set) var storeProducts: [Product] = []
    @Published var selectedProduct: SubscriptionProduct?
    @Published private(set) var purchasedSubscription: SubscriptionProduct?
    @Published private(set) var serverProductResponse: ServerProductResponse?
    @Published private(set) var availableProducts: [SubscriptionProduct] = []
    @Published private(set) var productIds: [String] = []
    
    var yearlyProducts: [SubscriptionProduct] {
        return availableProducts.filter { $0.recurringSubscriptionPeriod.isYearly }
    }
    
    var monthlyProducts: [SubscriptionProduct] {
        return availableProducts.filter { $0.recurringSubscriptionPeriod.isMonthly }
    }
    
    var weeklyProducts: [SubscriptionProduct] {
        return availableProducts.filter { $0.recurringSubscriptionPeriod.isWeekly }
    }
    
    var updateListenerTask: Task<Void, Error>? = nil
    
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
    
    // observable methods
    @MainActor
    private func updateProductIds() {
        productIds = serverProducts.map { $0.id };
    }
    
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
    func updateCustomerProductStatus() async {
        if userSubscriptionDetails.isEmpty {
            print("userSubscriptionDetails is empty")
            return
        }
        var purchasedSubcriptionId: String?
        
        for await result in Transaction.currentEntitlements {
            switch result {
            case .unverified:
                continue
            case .verified(let transaction):
                if transaction.productID == userSubscriptionDetails.first?.id {
                    purchasedSubcriptionId = transaction.productID
                }
            }
        }
        
        if let subscribedProduct = availableProducts.first(where: { $0.id ==  purchasedSubcriptionId}) {
            self.purchasedSubscription = subscribedProduct
        }
        
        await updateSubscriptionStatus()
        self.isLoading = false
    }
    
    @MainActor
    func loadCacheProducts() {
        guard let cache = CacheManager.loadLocalCache() else {
            return
        }
        if !cache.products.isEmpty {
            availableProducts = cache.products
        }
        
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        if purchasedSubscription != nil {
            isSubscribed = true
        } else {
            isSubscribed = false
        }
    }
    
    @MainActor
    private func updateAvaiableProducts() {
        let products: [Product] = storeProducts.filter { prod in
            serverProducts.contains { $0.id == prod.id }
        }
        availableProducts =  Helpers.sortByPrice(SubscriptionProduct.mapSubscriptionProducts(from: products))
        
        if let timeStamp = serverProductResponse?.timeStamp {
            let cacheData = SubscriptionProductCache(timeStamp: timeStamp,
                                                     products: availableProducts)
            CacheManager.saveLocalCache(cacheData)
        }
    }
    
    @MainActor
    func checkCachedAvailableProducts() async {
        let timeStamp = serverProductResponse?.timeStamp
        let isCached = CacheManager.isProductCached(timeStamp)
        if isCached {
            print("Cache found")
            let localCache = CacheManager.loadLocalCache()
            if let products = localCache?.products {
                availableProducts = products
            }
        } else {
            print("Cache Not found")
            await fetchStoreProducts()
        }
    }
    
    func setError(_ title: String, _ description: String) {
        error = ErrorModel(title: "Error", message: "No Products available.")
    }
    
    // StoreKit 2 calls
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try result.payloadValue
                    await transaction.finish()
                } catch {
                    print("Transaction failed in listenForTransactions")
                }
            }
        }
    }
    
    @MainActor
    func fetchStoreProducts() async {
        if(productIds.isEmpty) {
            setError("Error", "No Products available.");
            return
        }
        
        do {
            let sk2Products = try await storekitService.fetchProductsFromAppStore(for: productIds)
            storeProducts = sk2Products
            self.updateAvaiableProducts();
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
    func fetchSubscriptionPlans(apiKey: String) async {
        do {
            self.serverProducts = try await appService.loadSubscriptionPlans(apiKey: apiKey)
            self.updateProductIds();
        } catch {
            let errorMessage = "Failed to load subscription plans: \(error.localizedDescription)"
            setError("Error", errorMessage);
            self.isLoading = false
            print("fetchSubscriptionPlans - \(error)")
        }
    }
    
    @MainActor
    func purchaseProduct(with subscriptionProduct: SubscriptionProduct) async {
        print("subscriptionProduct id = \(subscriptionProduct.productId)")
        isPurchaseInProgress = true
        if storeProducts.isEmpty {
            await fetchStoreProducts()
        }
        guard let product = storeProducts.first(where: { $0.id == subscriptionProduct.productId }) else {
            setError("Error", "Product not found in App Store");
            return
        }
        do {
            let result = try await storekitService.purchaseStoreProduct(product, userId)
            switch result {
            case .success(let verification):
                let receipt = verification.jwsRepresentation
                try await appService.sendVerifiedCheck(userId, apiKey, receipt)
                
                self.purchasedSubscription = subscriptionProduct
                self.selectedProduct = nil
                let transaction: Transaction = try Helpers.checkVerified(verification)
                await transaction.finish()
                error = nil
            case .userCancelled:
                // setError("Error", "Purchase Cancelled");
               error = nil
                
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
    func fetchUserSubscriptionDetails() async {
        do {
            let subsDetails = try await appService.getUserSubscriptionDetails(for: userId, with: apiKey)
            self.userSubscriptionDetails = subsDetails
        } catch {
            print("Error fetching user subscription details.")
        }
    }
}
