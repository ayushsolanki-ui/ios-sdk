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
}
