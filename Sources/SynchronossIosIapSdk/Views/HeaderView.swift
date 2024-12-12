import SwiftUI

struct HeaderView: View {
    @AppStorage("subscribed") private var subscribed: Bool = false
    @EnvironmentObject var store: PaymentStore
    
    var body: some View {
        ZStack {
            VStack {
                Text(subscribed ? "Thanks for subscribing \(store.userId)!" : "Choose a plan \(store.userId)")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text(subscribed ?  "You are subscribed" : "A purchase is required to use this app")
                if subscribed {
                    goToSubscriptionButton
                }
                Image(.sdkicon)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 100)
                    .padding()
            }
            .padding(.vertical)
        }
    }
}

extension HeaderView {
    private var goToSubscriptionButton: some View {
        Button(action: {
            do {
                try AppUtils.openSubscriptionSettings()
            } catch {
                store.errorMessage = error.localizedDescription
            }
        }) {
            Text("Go To Subscriptions")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.red)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
}

