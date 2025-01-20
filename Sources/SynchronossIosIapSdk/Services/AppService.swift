import Foundation

// MARK: - Protocol Definition

/// A protocol defining the necessary API calls for the application.
protocol AppServiceProtocol {
    /// Fetches the application theme from the server.
    ///
    /// - Parameter apiKey: The API key for authentication.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing an array of `ServerThemeModel`.
    func getAppTheme(_ apiKey: String) async throws -> BaseResponse<[ServerThemeModel]>
    
    /// Fetches the user's subscription details from the server.
    ///
    /// - Parameters:
    ///   - userId: The user's identifier.
    ///   - apiKey: The API key for authentication.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing `ActiveUserResponse`.
    func getUserSubscriptionDetails(for userId: String, with apiKey: String) async throws -> BaseResponse<ActiveUserResponse>
    
    /// Loads the available subscription plans from the server.
    ///
    /// - Parameter apiKey: The API key for authentication.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing an array of `ServerProduct`.
    func loadSubscriptionPlans(_ apiKey: String) async throws -> BaseResponse<[ServerProduct]>
    
    /// Sends a verified purchase check to the server.
    ///
    /// - Parameters:
    ///   - userId: The user's identifier.
    ///   - apiKey: The API key for authentication.
    ///   - receipt: The receipt string.
    ///   - transaction: The optional `Transaction` associated with the purchase.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing `UserSubscriptionDetails`.
    func sendVerifiedCheck(
        _ userId: String,
        _ apiKey: String,
        _ receipt: String,
        _ transaction: Transaction?
    ) async throws -> BaseResponse<UserSubscriptionDetails>
}

// MARK: - StoreService Implementation

/// A service responsible for handling API calls related to themes, subscriptions, and purchases.
struct AppService: AppServiceProtocol {
    // Base URL for API requests
    let baseUrl = "https://sync-api.blr0.geekydev.com"
    let headerXApiKey = "x-api-key"
    
    // URLSession instance for making network requests
    let session: URLSession
    
    /// Initializes the `AppService` with a given `URLSession`.
    ///
    /// - Parameter session: The `URLSession` instance to use. Defaults to `.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Fetches the application theme from the server.
    ///
    /// - Parameter apiKey: The API key for authentication.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing an array of `ServerThemeModel`.
    func getAppTheme(_ apiKey: String) async throws -> BaseResponse<[ServerThemeModel]> {
        // Construct the URL safely without force unwrapping
        guard let url = URL(string: baseUrl + "/api/theme") else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: headerXApiKey)
        
        do {
            let (data, _) = try await session.data(for: request)
            let themeList = try JSONDecoder().decode(BaseResponse<[ServerThemeModel]>.self, from: data)
            return themeList
        } catch {
            // Consider replacing print with a logging framework in the future
            print("theme error = \(error)")
            throw error
        }
    }

    /// Fetches the user's subscription details from the server.
    ///
    /// - Parameters:
    ///   - userId: The user's identifier.
    ///   - apiKey: The API key for authentication.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing `ActiveUserResponse`.
    func getUserSubscriptionDetails(for userId: String, with apiKey: String) async throws -> BaseResponse<ActiveUserResponse> {
        // Ensure userId is properly URL-encoded to prevent malformed URLs
        guard let encodedUserId = userId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: baseUrl + "/api/iap/" + encodedUserId + "/Active") else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: headerXApiKey)
        
        do {
            let (data, _) = try await session.data(for: request)
            let resp = try JSONDecoder().decode(BaseResponse<ActiveUserResponse>.self, from: data)
            return resp
        } catch {
            // Consider replacing print with a logging framework in the future
            print("userSubDetails error= \(error)")
            throw error
        }
    }
    
    /// Loads the available subscription plans from the server.
    ///
    /// - Parameter apiKey: The API key for authentication.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing an array of `ServerProduct`.
    func loadSubscriptionPlans(_ apiKey: String) async throws -> BaseResponse<[ServerProduct]> {
        // Construct the URL safely without force unwrapping
        guard let url = URL(string: baseUrl + "/api/core/app/product") else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: headerXApiKey)
        
        do {
            let (data, _) = try await session.data(for: request)
            let products = try JSONDecoder().decode(BaseResponse<[ServerProduct]>.self, from: data)
            return products
        } catch {
            // Consider replacing print with a logging framework in the future
            throw error
        }
    }
    
    /// Sends a verified purchase check to the server.
    ///
    /// - Parameters:
    ///   - userId: The user's identifier.
    ///   - apiKey: The API key for authentication.
    ///   - receipt: The receipt string.
    ///   - transaction: The optional `Transaction` associated with the purchase.
    /// - Throws: An error if the request fails or decoding fails.
    /// - Returns: A `BaseResponse` containing `UserSubscriptionDetails`.
    func sendVerifiedCheck(
        _ userId: String,
        _ apiKey: String,
        _ receipt: String,
        _ transaction: Transaction?
    ) async throws -> BaseResponse<UserSubscriptionDetails> {
        
        let transactionDetails = TransactionDetails.mapTransactionToDetails(userId, receipt, transaction)
        let urlString = baseUrl + "/api/iap/ios/handle"
        
        // Safely construct the URL without force unwrapping
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: headerXApiKey)
        
        // Encode transaction details into JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        do {
            let jsonData = try encoder.encode(transactionDetails)
            request.httpBody = jsonData
        } catch {
            print("Encoding error: \(error)")
            throw error
        }
        
        do {
            let (data, _) = try await session.data(for: request)
            let transaction = try JSONDecoder().decode(BaseResponse<UserSubscriptionDetails>.self, from: data)
            return transaction
        } catch {
            throw error
        }
    }
}
