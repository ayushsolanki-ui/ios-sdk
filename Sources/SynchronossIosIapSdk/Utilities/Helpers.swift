import Foundation
import StoreKit

struct Helpers {
    static func sortByPrice(_ products: [ServerProduct]) -> [ServerProduct] {
        products.sorted(by: {return $0.price > $1.price})
    }

    static func getSubscriptionGroupIdentifier(for transaction: Transaction, from storeProducts: [Product]) -> String? {
        if let product = storeProducts.first(where: { $0.id == transaction.productID }) {
            return product.subscription?.subscriptionGroupID
        }
        return nil
    }
    
    static func checkVerified<T> (_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    static func getStoreProduct(with productId: String, from storeProducts: [Product]) -> Product? {
        return storeProducts.first(where: { $0.id == productId })
    }
    
    static func getServerProduct(with productId: String, from serverProduct: [ServerProduct]) -> ServerProduct? {
        return serverProduct.first(where: { $0.id == productId })
    }
    
    static func isProductPurchased(_ productId: String, _ product: ServerProduct?) -> Bool {
        if product != nil, product?.id == productId {
            return true
        }
        return false
    }
}
