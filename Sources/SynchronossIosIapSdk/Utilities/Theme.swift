import SwiftUI

struct Theme {
    static let primary = Color(hex: "#1F2937")
    static let secondary = Color(hex: "#6B7280")
    static let blue = Color(hex: "0096D5")
    static let lightBlue = Color(hex: "#E7F8FF")
    static let green = Color(hex: "#2A7948")
    static let greenLight = Color(hex: "#E4FFF4")
    static let gradientLeft = Color(hex: "#A954D4")
    static let gradientRight = Color(hex: "#3AD8EC")
    static let border = Color(hex: "#E5E7EB")
    static let orange = Color(hex: "#D76C1F")
    static let orangeLight = Color(hex: "#FFF9F5")
    static let orangeBorder = Color(hex: "#FECDAA")
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

