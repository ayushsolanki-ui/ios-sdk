import Foundation
import SwiftUI

struct AppUtils {
    @MainActor
    static func detectSandboxEnvironment() -> Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }
}
