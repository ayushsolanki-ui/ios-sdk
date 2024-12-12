import Foundation

struct AppService {
    func getUserSubscriptionDetails(for userId: String, with apiKey: String) async throws -> UserSubscriptionDetails {
        do {
            let url = URL(string: "https://05052a84-35de-4a87-ae64-2b32a9188b68.mock.pstmn.io/userSubscriptionDetails")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            let jsonData = try encoder.encode(UserSubscriptionDetailsPayload(userId: userId))
            request.httpBody = jsonData
            let (data, _) = try await URLSession.shared.data(for: request)
            let userSubDetails = try JSONDecoder().decode(UserSubscriptionDetails.self, from: data)
            print("User subs - \(userSubDetails)")
            return userSubDetails
        } catch {
            throw error
        }
    }
    
    func loadSubscriptionPlans(apiKey: String) async throws -> [ServerProduct] {
        do {
            let url = URL(string: "https://05052a84-35de-4a87-ae64-2b32a9188b68.mock.pstmn.io/productDetails")!
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            let products = try JSONDecoder().decode([ServerProduct].self, from: data)
            return products
        } catch {
            throw error
        }
    }
    
    func sendVerifiedCheck(transaction: TransactionDetails, apiKey: String) async throws {
        let urlString = "https://05052a84-35de-4a87-ae64-2b32a9188b68.mock.pstmn.io/transaction"
        let url = URL(string: urlString)
                
        if let url = url {
            do{
                // create request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                let session = URLSession.shared
                // send the request

                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "Authorization")
                // Encode the TransactionDetails into JSON
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .millisecondsSince1970
                let jsonData = try encoder.encode(transaction)

                // Set the HTTP body to the encoded JSON
                request.httpBody = jsonData
                let (data, _) = try await session.data(for: request);
                print("Post API response = \(data)")
            } catch {
                throw error
            }
        }
    }
}
