import Foundation

struct ThemeModel: Decodable {
    let light: ThemeData
    let dark: ThemeData
}

struct ThemeData: Decodable {
    let logoUrl: String?
    let primary: String
    let secondary: String
    let background: String
    let text: TextType
    let action: Action
    let success: Success
    let warning: Warning
    let error: ErrorTheme
}

struct TextType: Decodable {
    let primary: String
    let secondary: String
}

struct Action: Decodable {
    let primary: String
    let secondary: String
}

struct Success: Decodable {
    let primary: String
    let secondary: String
}

struct Warning: Decodable {
    let primary: String
    let secondary: String
    let tertiary: String
}

struct ErrorTheme: Decodable {
    let primary: String
    let secondary: String
}
