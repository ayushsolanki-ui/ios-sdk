import SwiftUI

/// A view that displays an environment warning if the app is running in a sandbox environment.
struct AppEnvironmentView: View {
    /// Indicates whether the app is running in a sandbox environment.
    private let isSandboxEnvironment = AppUtils.detectSandboxEnvironment()
    
    var body: some View {
        if isSandboxEnvironment {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(Theme.font(size: 14))
                    .foregroundColor(Theme.warningPrimary)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.important)
                        .font(Theme.font(size: 12))
                        .foregroundColor(Theme.warningPrimary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(LocalizedString.sandboxMessage)
                        .font(Theme.font(size: 12))
                        .lineSpacing(4)
                        .foregroundColor(Theme.textSecondary)
                        .accessibilityLabel(LocalizedString.sandboxMessage)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.warningSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.warningTertiary, lineWidth: 1)
                    )
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel(LocalizedString.environmentWarning)
        }
    }
}

 // MARK: - Localized Strings
private struct LocalizedString {
    static let important = NSLocalizedString("Important", comment: "Important label for sandbox environment warning")
    static let sandboxMessage = NSLocalizedString("You are using a Sandbox Environment. Transactions made here are for testing purposes only and will not result in actual changes.", comment: "Sandbox environment message")
    static let environmentWarning = NSLocalizedString("Sandbox Environment Warning", comment: "Accessibility label for sandbox environment warning")
}
