import Foundation
import StoreKit

protocol StoreKitServicing {
    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product]
    func purchaseStoreProduct(_ product: Product, _ userId: String) async throws -> Product.PurchaseResult
    func sendTransactionDetails(for transaction: Transaction, with userId: String, using apiKey: String, of product: SubscriptionProduct) async throws
}

struct StoreKitService: StoreKitServicing {
    let appService = AppService();

    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product] {
        if(productIds.isEmpty) {
            throw StoreError.noProducts
        }
        do {
            let allStoreProducts = try await Product.products(for: productIds)
            if allStoreProducts.count == 0 {
                throw StoreError.noProductsInStore
            }
            return allStoreProducts
        } catch {
            print("fetchProductsFromAppStore error = \(error)")
            throw error;
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

    func sendTransactionDetails(for transaction: Transaction, with userId: String, using apiKey: String, of product: SubscriptionProduct) async throws {
        
        let mappedTransaction = TransactionDetails.mapTransactionToDetails(for: transaction, with: userId, of: product);
        do{
            try await appService.sendVerifiedCheck(transaction: mappedTransaction, apiKey: apiKey)
        } catch {
            throw error
        }
    }
}
