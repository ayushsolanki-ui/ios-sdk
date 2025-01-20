import Foundation
import SwiftUI

/// A utility struct providing theme-related constants and methods.
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
        action: Action(primary: "#F9FAFB", secondary: "#212121"),
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
    
    /// The logo URL of the current theme.
    static var logoUrl: String {
        currentThemeData.logoUrl ?? ""
    }
    
    // MARK: - Top-level Colors
    /// The primary color of the current theme.
    static var primary: Color {
        Color(hex: currentThemeData.primary)
    }
    
    /// The secondary color of the current theme.
    static var secondary: Color {
        Color(hex: currentThemeData.secondary)
    }
    
    /// The background color of the current theme.
    static var background: Color {
        Color(hex: currentThemeData.background)
    }
    
    // MARK: - Text
    /// The primary text color of the current theme.
    static var textPrimary: Color {
        Color(hex: currentThemeData.text.primary)
    }
    
    /// The secondary text color of the current theme.
    static var textSecondary: Color {
        Color(hex: currentThemeData.text.secondary)
    }
    
    // MARK: - Action
    /// The primary action color of the current theme.
    static var actionPrimary: Color {
        Color(hex: currentThemeData.action.primary)
    }
    
    /// The secondary action color of the current theme.
    static var actionSecondary: Color {
        Color(hex: currentThemeData.action.secondary)
    }
    
    // MARK: - Success
    /// The primary success color of the current theme.
    static var successPrimary: Color {
        Color(hex: currentThemeData.success.primary)
    }
    
    /// The secondary success color of the current theme.
    static var successSecondary: Color {
        Color(hex: currentThemeData.success.secondary)
    }
    
    // MARK: - Warning
    /// The primary warning color of the current theme.
    static var warningPrimary: Color {
        Color(hex: currentThemeData.warning.primary)
    }
    
    /// The secondary warning color of the current theme.
    static var warningSecondary: Color {
        Color(hex: currentThemeData.warning.secondary)
    }
    
    /// The tertiary warning color of the current theme.
    static var warningTertiary: Color {
        Color(hex: currentThemeData.warning.tertiary)
    }
    
    // MARK: - Error
    /// The primary error color of the current theme.
    static var errorPrimary: Color {
        Color(hex: currentThemeData.error.primary)
    }
    
    /// The secondary error color of the current theme.
    static var errorSecondary: Color {
        Color(hex: currentThemeData.error.secondary)
    }
    
    // MARK: - Fonts
    /// Returns a system font with the specified size.
    ///
    /// - Parameter size: The size of the font.
    /// - Returns: A `Font` instance.
    static func font(size: CGFloat) -> Font {
        Font.system(size: size)
    }
}

extension Theme {
    /// Merges the fallback theme with the given `ServerThemeModel`,
    /// overriding only `logoUrl`, `primary`, and `secondary`.
    ///
    /// - Parameters:
    ///   - fallback: The fallback `ThemeData`.
    ///   - serverTheme: The `ServerThemeModel` to merge.
    /// - Returns: A new `ThemeData` instance with merged values.
    static func mergeTheme(_ fallback: ThemeData, with serverTheme: ServerThemeModel) -> ThemeData {
        ThemeData(
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

/// An extension to initialize `Color` from a hex string.
extension Color {
    /// Initializes a `Color` instance from a hexadecimal string.
    ///
    /// - Parameter hex: The hexadecimal string representing the color (e.g., "#FFFFFF").
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
