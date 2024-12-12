import Foundation

struct ServerProduct: Codable, Identifiable {
    var id: String {
        return productId
    }
    let productId: String
}
