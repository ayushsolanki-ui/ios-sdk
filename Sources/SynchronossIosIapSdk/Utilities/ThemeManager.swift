@MainActor
final class ThemeManager {
    static let shared = ThemeManager()
    var themeData: ThemeModel?

    func updateTheme(with themes: [ServerThemeModel]) {
        // Start with the default fallback themes
        var updatedLight = Theme.fallbackLightTheme
        var updatedDark = Theme.fallbackDarkTheme

        // Merge server data into the fallback themes
        for serverTheme in themes {
            let themeName = serverTheme.themeName.lowercased()
            if themeName == "light" {
                updatedLight = Theme.mergeTheme(updatedLight, with: serverTheme)
            } else if themeName == "dark" {
                updatedDark = Theme.mergeTheme(updatedDark, with: serverTheme)
            }
        }

        // Build our ThemeModel with updated values
        self.themeData = ThemeModel(light: updatedLight, dark: updatedDark)
    }
}
