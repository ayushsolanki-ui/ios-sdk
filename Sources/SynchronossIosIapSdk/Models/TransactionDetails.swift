import Foundation

struct TransactionDetails: Codable {
    let userId: String
    let deviceVerificationNonce: String
    let receipt: String
    
    static func mapTransactionToDetails(_ userId: String, _ receipt: String) -> TransactionDetails {
        return TransactionDetails(
            userId: userId,
            deviceVerificationNonce: receipt,
            receipt: receipt
        )
    }
}
