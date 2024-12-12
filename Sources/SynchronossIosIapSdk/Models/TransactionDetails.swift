import Foundation

struct TransactionDetails: Codable {
    let userId: String
    let appAccountToken: UUID
    let bundleId: String
    let deviceVerification: String
    let deviceVerificationNonce: String
    let expiresDate: TimeInterval
    let inAppOwnershipType: String
    let isUpgraded: Bool
    let originalPurchaseDate: TimeInterval
    let originalTransactionId: UInt64
    let price: Decimal
    let productId: String
    let purchaseDate: TimeInterval
    let quantity: Int
    let signedDate: TimeInterval
    let transactionId: String
    let type: String
    let webOrderLineItemId: String
    
    let purchasedProduct: SubscriptionProduct
    
    static func mapTransactionToDetails(for transaction: Transaction, with userId: String, of product: SubscriptionProduct) -> TransactionDetails {
        return TransactionDetails(
                userId: userId,
                appAccountToken: transaction.appAccountToken ?? UUID(),
                bundleId: transaction.appBundleID,
                deviceVerification: transaction.deviceVerification.base64EncodedString(),
                deviceVerificationNonce: transaction.deviceVerificationNonce.uuidString,
                expiresDate: transaction.expirationDate?.timeIntervalSince1970 ?? 0,
                inAppOwnershipType: transaction.ownershipType.rawValue,
                isUpgraded: transaction.isUpgraded,
                originalPurchaseDate: transaction.originalPurchaseDate.timeIntervalSince1970,
                originalTransactionId: transaction.originalID,
                price: transaction.price ?? Decimal(0),
                productId: transaction.productID,
                purchaseDate: transaction.purchaseDate.timeIntervalSince1970,
                quantity: transaction.purchasedQuantity,
                signedDate: transaction.signedDate.timeIntervalSince1970,
                transactionId: String(transaction.id),
                type: transaction.productType.rawValue,
                webOrderLineItemId: transaction.webOrderLineItemID ?? "",
                purchasedProduct: product
            )
    }
}
