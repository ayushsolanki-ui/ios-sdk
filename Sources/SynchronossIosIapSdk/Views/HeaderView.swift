import SwiftUI
import StoreKit

struct HeaderView: View {
    @EnvironmentObject var store: PaymentStore
    
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
                    
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                    
                    case .failure:
                        // Empty view if image fails to load
                        EmptyView()
                    
                    @unknown default:
                        EmptyView()
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await AppStore.sync()
            } catch {
                store.errorMessage = "Failed to restore"
                print("Failed to restore: \(error.localizedDescription)")
            }
        }
    }
    
    private var titleText: some View {
        Text("Add more storage to keep everything in one place")
            .foregroundColor(Theme.headingText)
            .font(Theme.font(size: 24))
            .fontWeight(.bold)
            .lineSpacing(4)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var restorePurchase: some View {
        Button(action: {
            restorePurchases()
        }) {
            Text("Restore purchase")
                .foregroundColor(Theme.headingText)
                .font(Theme.font(size: 12))
                .underline(true, color: Theme.headingText)
        }
        .padding()
    }
    
    // Unused for now
    private var goToSubscriptionButton: some View {
        Button(action: {
            do {
                try AppUtils.openSubscriptionSettings()
            } catch {
                store.errorMessage = error.localizedDescription
            }
        }) {
            Text("Go To Subscriptions")
                .font(Theme.font(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(.blue)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
}

