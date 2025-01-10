import Foundation

struct SubscriptionProductsCache: Codable {
    let timeStamp: Int64?
    let products: [ServerProduct]?
}

struct ThemeCache: Codable {
    let timeStamp: Int64?
    let theme: [ServerThemeModel]?
}

