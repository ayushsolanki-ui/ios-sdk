import SwiftUI
import StoreKit

/// A view that displays the header section, including the logo, title, tab switcher, and restore purchase button.
struct HeaderView: View {
    @EnvironmentObject private var store: PaymentStore
    
    var body: some View {
        VStack(spacing: 16) {
            logo
            titleText
            TabSwitcherView()
            restorePurchase
        }
    }
}

extension HeaderView {
    /// The logo image loaded asynchronously from a URL.
    private var logo: AnyView {
        if let url = URL(string: Theme.logoUrl) {
            return AnyView(
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color(white: 0.9))
                            .frame(width: 40, height: 40)
                            .shimmer()
                            .accessibilityHidden(true)
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .accessibilityLabel("App Logo")
                        
                    case .failure:
                        EmptyView()
                            .accessibilityHidden(true)
                        
                    @unknown default:
                        EmptyView()
                            .accessibilityHidden(true)
                    }
                }
            )
        } else {
            return AnyView(
                EmptyView()
                    .accessibilityHidden(true)
            )
        }
    }
    
    /// Restores previously completed purchases.
    private func restorePurchases() {
        Task {
            do {
                try await AppStore.sync()
            } catch {
                store.setError(LocalizedString.errorTitle, LocalizedString.restoreFailed)
                print("Failed to restore purchases: \(error.localizedDescription)")
            }
        }
    }
    
    /// The title text describing the feature.
    private var titleText: some View {
        Text(LocalizedString.titleDescription)
            .foregroundColor(Theme.textPrimary)
            .font(Theme.font(size: 24))
            .fontWeight(.bold)
            .lineSpacing(4)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(LocalizedString.titleDescription)
    }
    
    /// A button that allows users to restore their purchases.
    private var restorePurchase: some View {
        Button(action: {
            restorePurchases()
        }) {
            Text(LocalizedString.restorePurchase)
                .foregroundColor(Theme.actionPrimary)
                .font(Theme.font(size: 12))
                .underline(true, color: Theme.actionPrimary)
        }
        .padding()
        .accessibilityLabel(LocalizedString.restorePurchase)
        .accessibilityHint(LocalizedString.restorePurchaseHint)
    }
}

// MARK: - Localized Strings
private struct LocalizedString {
    static let titleDescription = NSLocalizedString(
        "Add more storage to keep everything in one place",
        comment: "Description for the storage feature"
    )
    
    static let restorePurchase = NSLocalizedString(
        "Restore purchase",
        comment: "Button title to restore purchases"
    )
    
    static let restorePurchaseHint = NSLocalizedString(
        "Tap to restore your previous purchases.",
        comment: "Accessibility hint for restore purchase button"
    )
    
    static let errorTitle = NSLocalizedString(
        "Error",
        comment: "Error title for alerts"
    )
    
    static let restoreFailed = NSLocalizedString(
        "Failed to restore purchases.",
        comment: "Error message when restoring purchases fails"
    )
}
