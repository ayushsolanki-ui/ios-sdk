import SwiftUI

/// Fallback variant matching your "light" theme in the JSON
let fallbackLightThemeVariant = ThemeVariant.Colors(
    primary: "#0096D5",
    secondary: "#E7F8FF",
    background: "#FFFFFF",
    text: TextColor(
        heading: "#1F2937",
        body: "#6B7280",
        bodyAlt: "#1F2937"
    ),
    surface: SurfaceColor(
        base: "#E4FFF4",
        onSurface: "#2A7948"
    ),
    outline: OutlineColor(
        defaultColor: "#E5E7EB",
        variant: "#0096D5"
    ),
    tertiary: TertiaryColor(
        base: "#FFFFFF",
        onTertiary: "#6B7280"
    ),
    warning: WarningColor(
        text: "#D76C1F",
        background: "#FFF9F5",
        border: "#FECDAA"
    ),
    error: ErrorColor(
        background: "#FFF9F5",
        border: "#FECDAA"
    )
)

/// Fallback variant matching your "dark" theme in the JSON
let fallbackDarkThemeVariant = ThemeVariant.Colors(
    primary: "#0096D5",
    secondary: "#262627",
    background: "#0D0D0D",
    text: TextColor(
        heading: "#C8D2E0",
        body: "#8C8C8C",
        bodyAlt: "#FEFEFF"
    ),
    surface: SurfaceColor(
        base: "#166534",
        onSurface: "#E4FFF4"
    ),
    outline: OutlineColor(
        defaultColor: "#262627",
        variant: "#404040"
    ),
    tertiary: TertiaryColor(
        base: "#212121",
        onTertiary: "#FEFEFF"
    ),
    warning: WarningColor(
        text: "#D76C1F",
        background: "#FFF9F5",
        border: "#FECDAA"
    ),
    error: ErrorColor(
        background: "#FFF9F5",
        border: "#FECDAA"
    )
)

@MainActor
public class ThemeManager {
    static let shared = ThemeManager()
    
    private(set) var themeData: ThemeData?
    private(set) var currentVariant: ThemeVariant.Colors?
    
    private init() {
        currentVariant = fallbackLightThemeVariant
    }
    
    public static func loadThemeFromJSON(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decodedTheme = try JSONDecoder().decode(ThemeData.self, from: data)
            
            // Set these on the shared instance
            shared.themeData = decodedTheme
            shared.currentVariant = decodedTheme.themes.light.colors
        } catch {
            print("Error decoding theme.json: \(error). Using fallback.")
            shared.currentVariant = fallbackLightThemeVariant
        }
    }
    
    /// Switch to dark mode
    func switchToDarkMode() {
        if let td = themeData {
            // Use the "dark" variant from the JSON
            currentVariant = td.themes.dark.colors
        } else {
            // If JSON is not available, use the fallback dark variant
            currentVariant = fallbackDarkThemeVariant
        }
    }
    
    /// Switch to light mode
    func switchToLightMode() {
        if let td = themeData {
            // Use the "light" variant from the JSON
            currentVariant = td.themes.light.colors
        } else {
            // If JSON is not available, use the fallback light variant
            currentVariant = fallbackLightThemeVariant
        }
    }
}

