import Foundation

/// An enumeration representing possible API-related errors.
enum ApiError: LocalizedError {
    case networkError
    case unauthorized
    case invalidURL
    case invalidUserId
    case unknown
    
    var localizedDescription: String? {
        switch self {
        case .networkError:
            return NSLocalizedString("Network Error!", comment: "Error when a network request fails.")
        case .unauthorized:
            return NSLocalizedString("You are not authorized to perform this action.", comment: "Error when the user is unauthorized.")
        case .invalidURL:
            return NSLocalizedString("The URL provided was invalid.", comment: "Error when the URL is malformed.")
        case .invalidUserId:
            return NSLocalizedString("The UserID provided is invalid.", comment: "Error in USER_ID.")
        case .unknown:
            return NSLocalizedString("An unknown error occurred. Please contact support.", comment: "Generic unknown error.")
        }
    }
}

/// An enumeration representing possible store-related errors.
public enum StoreError: LocalizedError {
    case failedVerification
    case noProducts
    case productRequestFailed
    case purchaseProductFailed
    case noProductsInStore
    
    var localizedDescription: String? {
        switch self {
        case .failedVerification:
            return NSLocalizedString("Failed to verify the product.", comment: "Error when product verification fails.")
        case .noProducts:
            return NSLocalizedString("No products available.", comment: "Error when no products are found.")
        case .productRequestFailed:
            return NSLocalizedString("Product request failed.", comment: "Error when fetching products fails.")
        case .purchaseProductFailed:
            return NSLocalizedString("Purchase failed.", comment: "Error when a product purchase fails.")
        case .noProductsInStore:
            return NSLocalizedString("No products are available in the store.", comment: "Error when the store has no products.")
        }
    }
}
