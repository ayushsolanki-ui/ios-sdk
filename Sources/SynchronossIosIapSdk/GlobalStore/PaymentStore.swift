import Foundation
import StoreKit
import SwiftUI

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

class PaymentStore: ObservableObject {
    @AppStorage("subscribed") private var isSubscribed: Bool = false
    @Published var serverProducts: [ServerProduct] = []
    @Published var isLoading = true
    @Published var showToast = false
    @Published var errorMessage: String?
    @Published var userSubscriptionDetails: UserSubscriptionDetails?
    @Published var isPurchaseInProgress: Bool = false
    @Published private(set) var storeProducts: [Product] = []
    @Published var selectedProduct: SubscriptionProduct?
    @Published private(set) var purchasedSubscriptions: [SubscriptionProduct] = []
    @Published private(set) var availableProducts: [SubscriptionProduct] = []
    @Published private(set) var productIds: [String] = []
    
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
        productIds = serverProducts.map { $0.productId };
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
            errorMessage = nil
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubs: [Product] = []

        var latestTransactions: [String: Transaction] = [:]

        for await result in Transaction.currentEntitlements {
            switch result {
            case .unverified:
                continue
            case .verified(let transaction):
                guard let subscriptionGroupId = Helpers.getSubscriptionGroupIdentifier(for: transaction, from: storeProducts) else {
                    continue
                }
                print("verified = \(transaction.productID)")
                if let existingTransaction = latestTransactions[subscriptionGroupId] {
                    if transaction.purchaseDate > existingTransaction.purchaseDate {
                        latestTransactions[subscriptionGroupId] = transaction
                    }
                } else {
                    latestTransactions[subscriptionGroupId] = transaction
                }
            }
        }
        
        let latestTransactionProductIDs = Set(Array(latestTransactions.values).map { $0.productID })
        print("latestTransactionProductIDs = \(latestTransactionProductIDs)")
        purchasedSubs = storeProducts.filter { product in
            latestTransactionProductIDs.contains(product.id)
        }
        
        self.purchasedSubscriptions = SubscriptionProduct.mapSubscriptionProducts(from: purchasedSubs)
        await updateSubscriptionStatus()
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        if purchasedSubscriptions.count > 0 {
            isSubscribed = true
        } else {
            isSubscribed = false
        }
    }
    
    @MainActor
    private func updateAvaiableProducts() {
        let products: [Product] = storeProducts.filter { prod in
            serverProducts.contains { $0.productId == prod.id }
        }
        availableProducts =  Helpers.sortByPrice(SubscriptionProduct.mapSubscriptionProducts(from: products))
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
            errorMessage = "No Products Ids available."
            self.isLoading = false
            return
        }
        
        do {
            let sk2Products = try await storekitService.fetchProductsFromAppStore(for: productIds)
            storeProducts = sk2Products
            self.updateAvaiableProducts();
            self.isLoading = false
        } catch StoreError.noProductsInStore {
            let errMsg = "Got 0 products in App store."
            errorMessage = errMsg
            self.isLoading = false
        } catch {
            let errMsg = "Failed to fetch App Store products: \(error.localizedDescription)"
            errorMessage = errMsg
            print("fetchStoreProducts - \(error)")
            self.isLoading = false
        }
    }
    
    // API calls
    @MainActor
    func fetchSubscriptionPlans(apiKey: String) async {
        do {
            self.serverProducts = try await appService.loadSubscriptionPlans(apiKey: apiKey)
            self.updateProductIds();
        } catch {
            self.errorMessage = "Failed to load subscription plans: \(error.localizedDescription)"
            self.isLoading = false
            print("fetchSubscriptionPlans - \(error)")
        }
    }
    
    @MainActor
    func purchaseProduct(with subscriptionProduct: SubscriptionProduct) async {
        print("subscriptionProduct id = \(subscriptionProduct.productId)")
        isPurchaseInProgress = true
        guard let product = storeProducts.first(where: { $0.id == subscriptionProduct.productId }) else {
            errorMessage = "Product not found in App Store"
            return
        }
        do {
            let result = try await storekitService.purchaseStoreProduct(product, userId)
            switch result {
            case .success(let verification):
                let transaction: Transaction = try Helpers.checkVerified(verification)
                print("purchase done - \(transaction)")
                try await storekitService.sendTransactionDetails(for: transaction, with: userId, using: apiKey, of: subscriptionProduct)
            
                await updateCustomerProductStatus()
                
                await transaction.finish()
                errorMessage = nil
            case .userCancelled:
                errorMessage = "User cancelled the purchase"
    
            case .pending:
                errorMessage = "Purchase is pending"
               
            default:
                errorMessage = "Unknown purchase result"
               
            }
            isPurchaseInProgress = false
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isPurchaseInProgress = false
        }
        
    }
    
    @MainActor
    func fetchUserSubscriptionDetails() async {
        do {
            let subDetails = try await appService.getUserSubscriptionDetails(for: userId, with: apiKey)
            self.userSubscriptionDetails = subDetails
        } catch {
            print("Error fetching user subscription details.")
        }
    }
}
