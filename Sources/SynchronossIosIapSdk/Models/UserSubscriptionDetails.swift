import Foundation
import StoreKit

struct UserSubscriptionDetails: Codable, Identifiable {
    var id: String {
        return productName
    }
    let productName: String
    let serviceLevel: String
    let vendorName: String
    let appName: String
    let appPlatformID: String
    let platform: String
    let partnerUserId: String
    let startDate: Int
    let endDate: Int
    let originalTransactionId: String
    let status: String
    let type: String
    let originalPurchaseDate: Int
}

struct UserSubscriptionDetailsPayload : Codable {
    let userId: String
}
