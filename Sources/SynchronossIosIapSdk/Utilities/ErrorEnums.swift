import Foundation

enum ApiError: Error {
    case networkError
    case unauthorized
    case unknown

    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Network Error!"
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .unknown:
            return "An unknown error occurred. Please contact support."
        }
    }
}

public enum StoreError: Error {
    case failedVerification
    case noProducts
    case productRequestFailed
    case purchaseProductFailed
    case noProductsInStore
}

enum AppError: Error {
    case openAppStoreSubscriptions
    
    var localizedDescription: String {
        switch self {
        case .openAppStoreSubscriptions:
            return "Failed to open subscriptions!"
        }
    }
}
