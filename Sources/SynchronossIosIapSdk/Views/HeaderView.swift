import SwiftUI
import StoreKit

struct HeaderView: View {
    @EnvironmentObject var store: PaymentStore
    
    var body: some View {
        VStack(spacing: 16) {
            if Theme.logoUrl.count != 0 {
                logo
            }
            titleText
            TabSwitcherView()
            restorePurchase
        }
    }
}

extension HeaderView {
    private var logo: some View {
        Image(Theme.logoUrl)
            .resizable()
            .scaledToFit()
            .frame(width: 120)
        
        
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
            .font(.system(size: 24).bold())
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var restorePurchase: some View {
        Button(action: {
            restorePurchases()
        }) {
            Text("Restore purchase")
                .foregroundColor(Theme.secondary)
                .font(.system(size: 12))
                .underline(true, color: Theme.secondary)
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
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(.blue)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
}

