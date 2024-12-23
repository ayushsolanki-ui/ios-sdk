import SwiftUI

struct HeaderView: View {
    @AppStorage("subscribed") private var subscribed: Bool = false
    @EnvironmentObject var store: PaymentStore
    
    var body: some View {
        ZStack {
            VStack {
                Image(.sdkicon)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 100)
                    .padding(.bottom, 10)
                Text(subscribed ? "Thanks for subscribing!" : "Choose a plan")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                if subscribed {
                    goToSubscriptionButton
                }
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

