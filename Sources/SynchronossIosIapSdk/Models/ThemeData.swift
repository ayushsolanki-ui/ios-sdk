import Foundation

struct ThemeData: Decodable {
    let shared: Shared
    let themes: Themes
    
    struct Shared: Decodable {
        let logoUrl: String
    }
    
    struct Themes: Decodable {
        let light: ThemeVariant
        let dark: ThemeVariant
    }
}

struct ThemeVariant: Decodable {
    let colors: Colors
    
    struct Colors: Decodable {
        let primary: String
        let secondary: String
        let background: String
        
        let text: TextColor
        let surface: SurfaceColor
        let outline: OutlineColor
        let tertiary: TertiaryColor
        let warning: WarningColor
        let error: ErrorColor
    }
}

struct TextColor: Decodable {
    let heading: String
    let body: String
    let bodyAlt: String
}

struct SurfaceColor: Decodable {
    let base: String
    let onSurface: String
}

struct OutlineColor: Decodable {
    let defaultColor: String
    let variant: String
}

struct TertiaryColor: Decodable {
    let base: String
    let onTertiary: String
}

struct WarningColor: Decodable {
    let text: String
    let background: String
    let border: String
}

struct ErrorColor: Decodable {
    let background: String
    let border: String
}
