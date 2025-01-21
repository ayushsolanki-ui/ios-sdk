import Foundation
import StoreKit

// MARK: - Protocol Definition

/// A protocol defining the necessary StoreKit service methods.
protocol StoreKitServicing {
    /// Fetches products from the App Store based on provided product identifiers.
    ///
    /// - Parameter productIds: An array of product identifiers to fetch.
    /// - Throws: `StoreError.noProducts` if `productIds` is empty.
    ///           `StoreError.noProductsInStore` if no products are found in the App Store.
    ///           Other errors related to network or decoding failures.
    /// - Returns: An array of `Product` fetched from the App Store.
    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product]
    
    /// Initiates the purchase process for a given product and user.
    ///
    /// - Parameters:
    ///   - product: The `Product` to purchase.
    ///   - userId: The user's identifier in UUID string format.
    /// - Throws: Errors related to the purchase process.
    /// - Returns: The result of the purchase operation.
    func purchaseStoreProduct(_ product: Product, _ userId: String) async throws -> Product.PurchaseResult
}

// MARK: - StoreKitService Implementation

/// A service responsible for interacting with StoreKit for product fetching and purchasing.
struct StoreKitService: StoreKitServicing {
    
    /// Fetches products from the App Store based on provided product identifiers.
    ///
    /// - Parameter productIds: An array of product identifiers to fetch.
    /// - Throws: `StoreError.noProducts` if `productIds` is empty.
    ///           `StoreError.noProductsInStore` if no products are found in the App Store.
    ///           Other errors related to network or decoding failures.
    /// - Returns: An array of `Product` fetched from the App Store.
    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product] {
        // Ensure that productIds is not empty
        guard !productIds.isEmpty else {
            throw StoreError.noProducts
        }
        
        do {
            // Fetch products from the App Store
            let allStoreProducts = try await Product.products(for: productIds)
            
            // Check if any products were returned
            guard !allStoreProducts.isEmpty else {
                throw StoreError.noProductsInStore
            }
            
            return allStoreProducts
        } catch {
            // Log the error (Consider using a logging framework instead of print)
            print("fetchProductsFromAppStore error = \(error)")
            throw error
        }
    }
    
    /// Initiates the purchase process for a given product and user.
    ///
    /// - Parameters:
    ///   - product: The `Product` to purchase.
    ///   - userId: The user's identifier in UUID string format.
    /// - Throws: Errors related to the purchase process.
    /// - Returns: The result of the purchase operation.
    func purchaseStoreProduct(_ product: Product, _ userId: String) async throws -> Product.PurchaseResult {
        do {
            // Validate and convert userId to UUID
//            guard let uuidFromUserId = UUID(uuidString: userId) else {
//                throw ApiError.invalidUserId
//            }
            let uuidFromUserId = UUID(uuidString: userId) ?? UUID()
            // Initiate the purchase with the user's UUID
            let result = try await product.purchase(options: [.appAccountToken(uuidFromUserId)])
            return result
        } catch {
            // Log the error (Consider using a logging framework instead of print)
            print("purchaseStoreProduct error = \(error)")
            throw error
        }
    }
}
