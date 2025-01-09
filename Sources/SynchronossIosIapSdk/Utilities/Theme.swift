import SwiftUI

@MainActor
struct Theme {
    /// Return the currently active Colors variant from ThemeManager,
    /// or fallback to the 'light' fallback if not available.
    private static var variant: ThemeVariant.Colors {
        ThemeManager.shared.currentVariant ?? fallbackLightThemeVariant
    }
    
    // MARK: - Shared
    /// For the logo URL, we can fetch directly from themeData?.shared.logoUrl
    /// If not available, you can provide a fallback or blank string.
    static var logoUrl: String {
        ThemeManager.shared.themeData?.shared.logoUrl ?? ""
    }
    
    // MARK: - Top-level Colors
    static var primary: Color {
        Color(hex: variant.primary)
    }
    
    static var secondary: Color {
        Color(hex: variant.secondary)
    }
    
    static var background: Color {
        Color(hex: variant.background)
    }
    
    // MARK: - Text
    static var headingText: Color {
        Color(hex: variant.text.heading)
    }
    
    static var bodyText: Color {
        Color(hex: variant.text.body)
    }
    
    static var bodyAltText: Color {
        Color(hex: variant.text.bodyAlt)
    }
    
    // MARK: - Surface
    static var surfaceBase: Color {
        Color(hex: variant.surface.base)
    }
    
    static var surfaceOnSurface: Color {
        Color(hex: variant.surface.onSurface)
    }
    
    // MARK: - Outline
    static var outlineDefault: Color {
        Color(hex: variant.outline.defaultColor)
    }
    
    static var outlineVariant: Color {
        Color(hex: variant.outline.variant)
    }
    
    // MARK: - Tertiary
    static var tertiaryBase: Color {
        Color(hex: variant.tertiary.base)
    }
    
    static var tertiaryOnTertiary: Color {
        Color(hex: variant.tertiary.onTertiary)
    }
    
    // MARK: - Warning
    static var warningText: Color {
        Color(hex: variant.warning.text)
    }
    
    static var warningBackground: Color {
        Color(hex: variant.warning.background)
    }
    
    static var warningBorder: Color {
        Color(hex: variant.warning.border)
    }
    
    // MARK: - Error
    static var errorBackground: Color {
        Color(hex: variant.error.background)
    }
    
    static var errorBorder: Color {
        Color(hex: variant.error.border)
    }
    
    // MARK: - Fonts
    static func font(size: CGFloat) -> Font {
        return Font.system(size: size)
    }
}

extension Color {
    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0x00ff00) >> 8
        let b = rgbValue & 0x0000ff
        
        self = Color(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

