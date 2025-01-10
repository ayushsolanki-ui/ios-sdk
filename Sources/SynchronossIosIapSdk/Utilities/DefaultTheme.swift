import SwiftUI

@MainActor
struct Theme {
    /// Default light theme
    static let fallbackLightTheme = ThemeData(
        logoUrl: "",
        primary: "#0096d5",
        secondary: "#E7F8FF",
        background: "#FFFFFF",
        text: TextType(primary: "#1F2937", secondary: "#6B7280"),
        action: Action(primary: "#6B7280", secondary: "#FFFFFF"),
        success: Success(primary: "#2A7948", secondary: "#E4FFF4"),
        warning: Warning(primary: "#D76C1F", secondary: "#FFF9F5", tertiary: "#FECDAA"),
        error: ErrorTheme(primary: "#F98181", secondary: "#FEF1F1")
    )
    
    /// Default dark theme
    static let fallbackDarkTheme = ThemeData(
        logoUrl: "",
        primary: "#0096d5",
        secondary: "#262627",
        background: "#0D0D0D",
        text: TextType(primary: "#FEFEFF", secondary: "#6B7280"),
        action: Action(primary: "##F9FAFB", secondary: "#212121"),
        success: Success(primary: "#E4FFF4", secondary: "#2A7948"),
        warning: Warning(primary: "#D76C1F", secondary: "#FFF9F5", tertiary: "#FECDAA"),
        error: ErrorTheme(primary: "#F98181", secondary: "#FEF1F1")
    )
    
    /// Returns the active theme based on the system's color scheme
    private static var currentThemeData: ThemeData {
        let colorScheme = UIScreen.main.traitCollection.userInterfaceStyle
        let isDarkMode = (colorScheme == .dark)
        
        if let theme = ThemeManager.shared.themeData {
            return isDarkMode ? theme.dark : theme.light
        }
        
        return isDarkMode ? fallbackDarkTheme : fallbackLightTheme
    }
    
    // MARK: - Shared
    static var logoUrl: String {
        currentThemeData.logoUrl ?? ""
    }
    
    // MARK: - Top-level Colors
    static var primary: Color {
        Color(hex: currentThemeData.primary)
    }
    
    static var secondary: Color {
        Color(hex: currentThemeData.secondary)
    }
    
    static var background: Color {
        Color(hex: currentThemeData.background)
    }
    
    // MARK: - Text
    static var textPrimary: Color {
        Color(hex: currentThemeData.text.primary)
    }
    
    static var textSecondary: Color {
        Color(hex: currentThemeData.text.secondary)
    }
    
    // MARK: - Action
    static var actionPrimary: Color {
        Color(hex: currentThemeData.action.primary)
    }
    
    static var actionSecondary: Color {
        Color(hex: currentThemeData.action.secondary)
    }
    
    // MARK: - Success
    static var successPrimary: Color {
        Color(hex: currentThemeData.success.primary)
    }
    
    static var successSecondary: Color {
        Color(hex: currentThemeData.success.secondary)
    }
    
    // MARK: - Warning
    static var warningPrimary: Color {
        Color(hex: currentThemeData.warning.primary)
    }
    
    static var warningSecondary: Color {
        Color(hex: currentThemeData.warning.secondary)
    }
    
    static var warningTertiary: Color {
        return Color(hex: currentThemeData.warning.tertiary)
    }
    
    // MARK: - Error
    static var errorPrimary: Color {
        Color(hex: currentThemeData.error.primary)
    }
    
    static var errorSecondary: Color {
        Color(hex: currentThemeData.error.secondary)
    }
    
    // MARK: - Fonts
    static func font(size: CGFloat) -> Font {
        Font.system(size: size)
    }
}
extension Theme {
    /// Merges the fallback theme with the given `ServerThemeModel`,
    /// overriding only `logoUrl`, `primary`, and `secondary`.
    static func mergeTheme(_ fallback: ThemeData, with serverTheme: ServerThemeModel) -> ThemeData {
        return ThemeData(
            logoUrl: !serverTheme.logoUrl.isEmpty ? serverTheme.logoUrl : fallback.logoUrl,
            primary: !serverTheme.primaryColor.isEmpty ? serverTheme.primaryColor : fallback.primary,
            secondary: !serverTheme.secondaryColor.isEmpty ? serverTheme.secondaryColor : fallback.secondary,
            background: fallback.background,
            text: fallback.text,
            action: fallback.action,
            success: fallback.success,
            warning: fallback.warning,
            error: fallback.error
        )
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
