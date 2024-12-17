import Foundation

struct ServerProduct: Codable, Identifiable {
    var id: String {
        return productName
    }
    let productName: String
}
