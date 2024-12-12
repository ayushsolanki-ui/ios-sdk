import Foundation
import StoreKit

struct UserSubscriptionDetails: Codable {
    let isSubscribed: Bool
    let subcriptionProduct: SubscriptionProduct?
}

struct UserSubscriptionDetailsPayload : Codable {
    let userId: String
}
