import SwiftUI

public struct RootPaymentView: View {
    @Environment(\.colorScheme) var colorScheme
    private let apiKey: String
    @State private var showToast: Bool = false
    @State private var isSheetPresented = false
    @StateObject private var store: PaymentStore
    
    public init(
        userId: String,
        apiKey: String
    ) {
        self.apiKey = apiKey
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
                .font(.system(.title, design: .default))
        }
        .background()
        
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
            AppUtils.applySystemColorScheme(colorScheme)
            Task{ @MainActor in
                await store.fetchUserSubscriptionDetails()
                await store.fetchSubscriptionPlans(apiKey: apiKey)
                await store.checkCachedAvailableProducts()
                await store.updateCustomerProductStatus()
            }
        }
        .onChange(of: store.errorMessage) { newValue in
            if newValue != nil {
                store.showToastForLimitedTime()
            }
        }
    }
    
    private var subscriptionButtonText: some View {
        Text("Subscriptions")
            .font(Theme.font(size: 20).weight(.semibold))
            .foregroundColor(.white)
            .frame(minWidth: 100, minHeight: 20)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
    }
    
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: {
                isSheetPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(Theme.font(size: 16))
                    .foregroundColor(Theme.bodyText)
            }
            .padding(.trailing, 16)
            .padding(.top, 16)
        }
    }
}
