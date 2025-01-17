import Foundation
import StoreKit

protocol StoreKitServicing {
    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product]
    func purchaseStoreProduct(_ product: Product, _ userId: String) async throws -> Product.PurchaseResult
}

struct StoreKitService: StoreKitServicing {
    let appService = AppService();
    
    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product] {
        if(productIds.isEmpty) {
            throw StoreError.noProducts
        }
        do {
            let allStoreProducts = try await Product.products(for: productIds)
            if allStoreProducts.isEmpty {
                throw StoreError.noProductsInStore
            }
            return allStoreProducts
        } catch {
            print("fetchProductsFromAppStore error = \(error)")
            throw error
        }
    }
    
    func purchaseStoreProduct(_ product: Product, _ userId: String) async throws -> Product.PurchaseResult {
        do {
            let uuidFromUserId = UUID(uuidString: userId) ?? UUID()
            let result = try await product.purchase(options: [.appAccountToken(uuidFromUserId)])
            return result
        } catch {
            throw error
        }
    }
}
