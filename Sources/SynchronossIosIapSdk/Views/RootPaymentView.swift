import SwiftUI

public struct RootPaymentView: View {
    private let apiKey: String
    @State private var showToast: Bool = false
    @StateObject private var store: PaymentStore
    
    public init(
        userId: String,
        apiKey: String
    ) {
        self.apiKey = apiKey
        _store = StateObject(wrappedValue: PaymentStore(userId: userId, apiKey: apiKey))
        
    }
    public var body: some View {
        ZStack {
            PaymentContentView()
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
}
