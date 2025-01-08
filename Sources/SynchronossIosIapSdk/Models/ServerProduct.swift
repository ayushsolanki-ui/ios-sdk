import Foundation

struct ServerProduct: Codable, Identifiable {
    var id: String {
        return productName
    }
    let productName: String
}

struct ServerProductResponse: Codable {
    let timeStamp: Int64
    let products: [ServerProduct]
}
