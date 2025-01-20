import SwiftUI

/// A view that handles the root payment interface.
public struct RootPaymentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSheetPresented = false
    @StateObject private var store: PaymentStore
    
    /// Initializes the RootPaymentView with a user ID and API key.
    /// - Parameters:
    ///   - userId: The user identifier.
    ///   - apiKey: The APP API key for authentication.
    public init(
        userId: String,
        apiKey: String
    ) {
        _store = StateObject(wrappedValue: PaymentStore(userId: userId, apiKey: apiKey))
    }
    
    public var body: some View {
        Button(action: {
            isSheetPresented = true
        }) {
            subscriptionButtonText
        }
        .padding()
        .sheet(isPresented: $isSheetPresented) {
            mainContent
                .background(Theme.background)
        }
    }
}

extension RootPaymentView {
    private var mainContent: some View {
        ZStack {
            VStack {
                closeButton
                PaymentContentView()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            ErrorView()
        }
        .environmentObject(store)
        .onAppear {
            Task { @MainActor in
                await store.initPaymentPlatform()
            }
        }
        .onChange(of: store.error?.message) { newValue in
            if newValue != nil {
                store.showToastForLimitedTime()
            }
        }
    }
    
    private var subscriptionButtonText: some View {
        Text("Upgrade Subscriptions")
            .font(Theme.font(size: 20))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(minWidth: 100, minHeight: 20)
            .padding()
            .background(Theme.primary)
            .cornerRadius(8)
            .accessibilityLabel("Subscribe to Premium")
    }
    
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: {
                isSheetPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(Theme.font(size: 16))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.trailing, 16)
            .padding(.top, 16)
            .accessibilityLabel("Close Payment Sheet")
        }
    }
}
