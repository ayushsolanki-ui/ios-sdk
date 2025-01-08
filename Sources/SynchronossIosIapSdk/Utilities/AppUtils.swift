import Foundation
import SwiftUI

struct AppUtils {
    @MainActor
    static func openSubscriptionSettings() throws {
        if let appStoreSubscriptionURL = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(appStoreSubscriptionURL, options: [:], completionHandler: nil)
        } else {
            throw AppError.openAppStoreSubscriptions
        }
    }
    
    @MainActor
    static func detectSandboxEnvironment() -> Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        if receiptURL.lastPathComponent == "sandboxReceipt" {
            return true
        } else {
            return false
        }
    }
    
    @MainActor
    static func applySystemColorScheme(_ scheme: ColorScheme) {
        if scheme == .dark {
            ThemeManager.shared.switchToDarkMode()
        } else {
            ThemeManager.shared.switchToLightMode()
        }
    }
}
