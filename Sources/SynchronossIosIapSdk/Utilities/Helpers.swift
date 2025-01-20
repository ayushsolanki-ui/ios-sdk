import Foundation
import StoreKit

/// A utility struct providing common helper functions for handling products and transactions.
struct Helpers {
    
    /// Sorts an array of `ServerProduct` instances by price in descending order.
    ///
    /// - Parameter products: The array of `ServerProduct` to sort.
    /// - Returns: A new array of `ServerProduct` sorted by price.
    static func sortByPrice(_ products: [ServerProduct]) -> [ServerProduct] {
        products.sorted { $0.price > $1.price }
    }

    /// Retrieves the subscription group identifier for a given transaction from the provided store products.
    ///
    /// - Parameters:
    ///   - transaction: The transaction for which to find the subscription group identifier.
    ///   - storeProducts: The array of `Product` instances from the store.
    /// - Returns: The subscription group identifier if found; otherwise, `nil`.
    static func getSubscriptionGroupIdentifier(for transaction: Transaction, from storeProducts: [Product]) -> String? {
        guard let product = storeProducts.first(where: { $0.id == transaction.productID }) else {
            return nil
        }
        return product.subscription?.subscriptionGroupID
    }
    
    /// Verifies the result of a purchase transaction.
    ///
    /// - Parameter result: The verification result to check.
    /// - Throws: `StoreError.failedVerification` if the result is unverified.
    /// - Returns: The verified and safe result.
    static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    /// Retrieves a `Product` from the store products by its identifier.
    ///
    /// - Parameters:
    ///   - productId: The identifier of the product to retrieve.
    ///   - storeProducts: The array of `Product` instances from the store.
    /// - Returns: The `Product` if found; otherwise, `nil`.
    static func getStoreProduct(with productId: String, from storeProducts: [Product]) -> Product? {
        storeProducts.first { $0.id == productId }
    }
    
    /// Retrieves a `ServerProduct` from the server products by its identifier.
    ///
    /// - Parameters:
    ///   - productId: The identifier of the server product to retrieve.
    ///   - serverProducts: The array of `ServerProduct` instances from the server.
    /// - Returns: The `ServerProduct` if found; otherwise, `nil`.
    static func getServerProduct(with productId: String, from serverProducts: [ServerProduct]) -> ServerProduct? {
        serverProducts.first { $0.id == productId }
    }
    
    /// Checks if a product is purchased based on its identifier.
    ///
    /// - Parameters:
    ///   - productId: The identifier of the product to check.
    ///   - product: The `ServerProduct` instance to verify.
    /// - Returns: `true` if the product is purchased; otherwise, `false`.
    static func isProductPurchased(_ productId: String, _ product: ServerProduct?) -> Bool {
        product?.id == productId
    }
}
