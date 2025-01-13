import Foundation

struct AppService {
    let baseUrl = "https://sync-api.blr0.geekydev.com"

    let session = URLSession.shared
    
    func getAppTheme(_ apiKey: String) async throws -> BaseResponse<[ServerThemeModel]> {
        do {
            let url = URL(string: baseUrl + "/api/theme")!
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            let (data, _) = try await session.data(for: request)
            let themeList = try JSONDecoder().decode(BaseResponse<[ServerThemeModel]>.self, from: data)
            return themeList
        } catch {
            print("theme error = \(error)")
            throw error
        }
    }

    func getUserSubscriptionDetails(for userId: String, with apiKey: String) async throws -> BaseResponse<ActiveUserResponse> {
        do {
            let url = URL(string: baseUrl + "/api/iap/" + userId + "/Active")!
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            let (data, _) = try await session.data(for: request)
            let resp = try JSONDecoder().decode(BaseResponse<ActiveUserResponse>.self, from: data)
            return resp
        } catch {
            print("userSubDetails errpr= \(error)")
            throw error
        }
    }
    
    func loadSubscriptionPlans(_ apiKey: String) async throws -> BaseResponse<[ServerProduct]> {
        do {
            let url = URL(string: baseUrl + "/api/core/app/product")!
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            let (data, _) = try await session.data(for: request)
            let products = try JSONDecoder().decode(BaseResponse<[ServerProduct]>.self, from: data)
            return products
        } catch {
            throw error
        }
    }
    
    func sendVerifiedCheck(
        _ userId: String,
        _ apiKey: String,
        _ receipt: String,
        _ transaction: Transaction
    ) async throws -> BaseResponse<UserSubscriptionDetails> {
        
        let transactionDetails = TransactionDetails.mapTransactionToDetails(userId, receipt, transaction)
        let urlString = baseUrl + "/api/iap/ios/handle"
        
        guard let url = URL(string: urlString) else {
            return BaseResponse(code: 500, title: "Error", message: "Wrong URL", data: nil)
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            let jsonData = try encoder.encode(transactionDetails)
            request.httpBody = jsonData
            
            let (data, _) = try await session.data(for: request)
            let transaction = try JSONDecoder().decode(BaseResponse<UserSubscriptionDetails>.self, from: data)
            return transaction
        } catch {
            throw error
        }
    }
}
