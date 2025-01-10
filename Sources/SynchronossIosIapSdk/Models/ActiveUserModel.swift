import Foundation

struct ActiveUserResponse: Codable {
    let subscriptionResponseDTO: UserSubscriptionDetails?
    let productUpdateTimeStamp: Int64?
    let themConfigTimeStamp: Int64?
}

struct UserSubscriptionDetails: Codable, Identifiable {
    var id: String {
        return productId
    }
    let productId: String
    let serviceLevel: String
    let vendorName: String
    let appName: String
    let appPlatformID: String
    let platform: String
    let partnerUserId: String
    let startDate: Int
    let endDate: Int
    let status: String
    let type: String
}

struct UserSubscriptionDetailsPayload : Codable {
    let userId: String
}
