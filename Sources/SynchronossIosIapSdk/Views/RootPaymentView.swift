import SwiftUI

public struct RootPaymentView: View {
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
            Task{ @MainActor in
                await store.fetchUserSubscriptionDetails()
                await store.fetchSubscriptionPlans(apiKey: apiKey)
                await store.fetchStoreProducts()
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
            .font(.headline)
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.trailing, 16)
            .padding(.top, 16)
        }
    }
}
