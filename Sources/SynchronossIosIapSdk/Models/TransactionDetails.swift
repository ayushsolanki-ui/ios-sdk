import Foundation

struct TransactionDetails: Codable {
    let partnerUserId: String
    let receipt: String
    let productId: String
    let originalTransactionId: UInt64
    
    static func mapTransactionToDetails(_ userId: String, _ receipt: String, _ transaction: Transaction?) -> TransactionDetails {
        return TransactionDetails(
            partnerUserId: userId,
            receipt: receipt,
            productId: transaction?.productID ?? "",
            originalTransactionId: transaction?.originalID ?? 0
        )
    }
}
