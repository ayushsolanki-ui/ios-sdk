import Foundation
import StoreKit
import SwiftUI

// Type aliases for StoreKit types to simplify usage
typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

/// A class responsible for managing in-app purchases, subscriptions, and related operations.
/// It conforms to `ObservableObject` to allow SwiftUI views to react to changes.
@MainActor
class PaymentStore: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Indicates whether the user is subscribed, stored persistently using `AppStorage`.
    @AppStorage("subscribed") private var isSubscribed: Bool = false
    
    /// The currently selected tab index in the UI.
    @Published var tabIndex: Int = 0
    
    /// Indicates whether a loading operation is in progress.
    @Published var isLoading = true
    
    /// Indicates whether a purchase operation is in progress.
    @Published var isPurchaseInProgress: Bool = false
    
    /// Controls the visibility of a toast message in the UI.
    @Published var showToast = false
    
    /// Holds the current error to be displayed in the UI.
    @Published var error: ErrorModel?
    
    /// An array of server-provided products available for purchase.
    @Published var serverProducts: [ServerProduct] = []
    
    /// An array of server-provided themes available for the application.
    @Published var vendorThemes: [ServerThemeModel]?
    
    /// Details about the active user's subscription.
    @Published var activeUserDetails: ActiveUserResponse?
    
    /// An array of StoreKit `Product` instances fetched from the App Store.
    @Published private(set) var storeProducts: [Product] = []
    
    /// The currently selected server product for purchase.
    @Published var selectedProduct: ServerProduct?
    
    /// The server product that has been successfully purchased.
    @Published private(set) var purchasedSubscription: ServerProduct?
    
    // MARK: - Computed Properties
    
    /// Filters server products to include only yearly subscriptions.
    var yearlyProducts: [ServerProduct] {
        return serverProducts.filter { $0.recurringPeriodCode.isYearly }
    }
    
    /// Filters server products to include only monthly subscriptions.
    var monthlyProducts: [ServerProduct] {
        return serverProducts.filter { $0.recurringPeriodCode.isMonthly }
    }
    
    /// Filters server products to include only weekly subscriptions.
    var weeklyProducts: [ServerProduct] {
        return serverProducts.filter { $0.recurringPeriodCode.isWeekly }
    }
    
    // MARK: - Private Properties
    
    /// A task that listens for transaction updates from StoreKit.
    var updateListenerTask: Task<Void, Error>? = nil
    
    /// An instance of `AppService` responsible for API interactions.
    var appService = AppService()
    
    /// An instance of `StoreKitService` responsible for StoreKit interactions.
    var storekitService = StoreKitService()
    
    /// The identifier for the current user.
    let userId: String
    
    /// The API key used for authenticating API requests.
    let apiKey: String
    
    // MARK: - Initializer
    
    /// Initializes the `PaymentStore` with a user ID and API key.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - apiKey: The API key for authenticating API requests.
    init(userId: String, apiKey: String) {
        self.userId = userId
        self.apiKey = apiKey
        // Start listening for transaction updates upon initialization
        updateListenerTask = listenForTransactions()
    }
    
    /// Cancels the transaction listener task upon deinitialization to prevent memory leaks.
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Initializes the payment platform by fetching user details, themes, products, and updating subscription status.
    @MainActor
    func initPaymentPlatform() async {
        isLoading = true
        defer { isLoading = false }
        await fetchActiveUserDetails()
        await handleCachedTheme()
        await handleCachedProducts()
        await updateSubscriptionStatus()
    }
    
    /// Sets the `AppService` instance, allowing for dependency injection.
    ///
    /// - Parameter appService: The `AppService` instance to be used.
    func setAppService(_ appService: AppService) {
        self.appService = appService
    }
    
    /// Sets the `StoreKitService` instance, allowing for dependency injection.
    ///
    /// - Parameter skService: The `StoreKitService` instance to be used.
    func setStoreKitService(_ skService: StoreKitService) {
        self.storekitService = skService
    }
    
    // MARK: - Observable Methods
    
    /// Displays a toast message for a limited time with an animation.
    ///
    /// The toast is shown with an animation, remains visible for 3 seconds, and then disappears with another animation.
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
    
    /// Handles the cached theme by fetching it from the cache or the server.
    ///
    /// If the theme is cached and valid, it is loaded from the cache. Otherwise, it is fetched from the server and cached.
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
    
    /// Handles the cached products by fetching them from the cache or the server.
    ///
    /// If the products are cached and valid, they are loaded from the cache. Otherwise, they are fetched from the server and cached.
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
    
    /// Handles a transaction by sending a verification check and updating subscription details.
    ///
    /// - Parameters:
    ///   - receipt: The receipt string associated with the transaction.
    ///   - transaction: The optional `Transaction` instance.
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
    
    /// Updates the subscription status based on the active user details.
    ///
    /// Sets the `purchasedSubscription` and updates the `isSubscribed` flag accordingly.
    @MainActor
    func updateSubscriptionStatus() async {
        guard let active = activeUserDetails,
              let subscribedProduct = active.subscriptionResponseDTO
        else {
            print("No Existing Subscriptions found!")
            return
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
    
    /// Sets the current error with a title and description.
    ///
    /// - Parameters:
    ///   - title: The title of the error.
    ///   - description: The description of the error.
    func setError(_ title: String, _ description: String) {
        error = ErrorModel(title: "Error", message: description)
    }
    
    // MARK: - StoreKit 2 Calls
    
    /// Listens for transaction updates from StoreKit and handles them accordingly.
    ///
    /// - Returns: A `Task` that continuously listens for transaction updates.
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
    
    /// Fetches StoreKit products based on the provided product identifiers.
    ///
    /// - Parameter productIds: An array of product identifiers to fetch.
    /// - Returns: An array of `Product` if successful; otherwise, `nil`.
    @MainActor
    func fetchStoreProducts(_ productIds: [String]) async -> [Product]? {
        if(productIds.isEmpty) {
            setError("Error", "No Products available.")
            return nil
        }
        
        do {
            let sk2Products = try await storekitService.fetchProductsFromAppStore(for: productIds)
            storeProducts = sk2Products
            return sk2Products
        } catch StoreError.noProductsInStore {
            let errMsg = "Got 0 products in App store."
            setError("Error", errMsg)
            return nil
        } catch {
            let errMsg = "Failed to fetch App Store products: \(error.localizedDescription)"
            setError("Error", errMsg)
            print("fetchStoreProducts - \(error)")
            return nil
        }
    }
    
    // MARK: - API Calls
    
    /// Fetches the application theme from the server.
    ///
    /// - Returns: An array of `ServerThemeModel` if successful; otherwise, an empty array.
    @MainActor
    func fetchAppTheme() async -> [ServerThemeModel] {
        do {
            let response = try await appService.getAppTheme(apiKey)
            guard let themes = response.data, response.code == 200 else {
                print("Theme Api Error")
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
    
    /// Fetches server products from the server.
    ///
    /// - Returns: An array of `ServerProduct` if successful; otherwise, an empty array.
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
            setError("Error", errorMessage)
            print("fetchServerProducts - \(error)")
            return []
        }
    }
    
    /// Initiates the purchase process for a given server product.
    ///
    /// - Parameter serverProduct: The `ServerProduct` to purchase.
    @MainActor
    func purchaseProduct(with serverProduct: ServerProduct) async {
        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }
        
        let purchasingProductId = serverProduct.id
        print("purchasingProductId id = \(purchasingProductId)")
        
        // Attempt to retrieve the StoreKit product
        let purchasingStoreProduct: Product? = Helpers.getStoreProduct(with: purchasingProductId, from: storeProducts)
        var products: [Product]?
        if storeProducts.isEmpty || purchasingStoreProduct == nil  {
            // Fetch products from the App Store if not already fetched
            products = await fetchStoreProducts([purchasingProductId])
        } else {
            products = [purchasingStoreProduct!]
        }
        
        guard let storeProducts = products,
              let storeProduct = Helpers.getStoreProduct(with: purchasingProductId, from: storeProducts) else {
            setError("Unavailable", "Product could not be found.")
            return
        }
        
        do {
            // Attempt to purchase the StoreKit product
            let result = try await storekitService.purchaseStoreProduct(storeProduct, userId)
            switch result {
            case .success(let verification):
                let receipt = verification.jwsRepresentation
                let transaction: Transaction = try Helpers.checkVerified(verification)
                await handleTransaction(receipt, transaction)
                print("Product purchase successful: \(purchasingProductId)")
                await transaction.finish()
            case .userCancelled:
                print("User cancelled the purchase")
            case .pending:
                setError("Error", "Purchase is pending")
            default:
                setError("Error", "Unknown purchase result")
            }
        } catch {
            let errorMessage = "Purchase failed: \(error.localizedDescription)"
            setError("Error", errorMessage)
        }
        
    }
    
    /// Fetches active user details from the server.
    ///
    /// Updates `activeUserDetails` if successful; otherwise, sets an error.
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
