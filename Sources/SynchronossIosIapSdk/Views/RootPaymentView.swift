import SwiftUI

public struct RootPaymentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isSheetPresented = false
    @StateObject private var store: PaymentStore
    
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
        Text("Subscriptions")
            .font(Theme.font(size: 20))
            .fontWeight(.semibold)
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
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.trailing, 16)
            .padding(.top, 16)
        }
    }
}
