import Foundation

struct BaseResponse<T: Codable & Sendable>: Codable, Sendable {
    let code: Int
    let title: String
    let message: String
    let data: T?
}


struct ActiveUserResponse: Codable {
    let subscriptionResponseDTO: UserSubscriptionDetails?
    let productUpdateTimeStamp: Int64?
    let themConfigTimeStamp: Int64?
}

struct UserSubscriptionDetails: Codable, Identifiable {
    var id: String {
        return product.productId
    }
    let product: ServerProduct
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
