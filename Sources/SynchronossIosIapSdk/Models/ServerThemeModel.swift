import Foundation

struct ServerThemeModel: Codable, Identifiable, Equatable {
    var id: String {
        return themeName
    }
    let themeName: String
    let logoUrl: String
    let primaryColor: String
    let secondaryColor: String
}
