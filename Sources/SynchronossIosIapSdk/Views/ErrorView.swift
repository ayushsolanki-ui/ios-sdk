import SwiftUI

struct ErrorView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        Group {
            if store.showToast, store.errorMessage != nil {
                VStack {
                    Spacer()
                    toastView
                }
            }
        }
    }
}

extension ErrorView {
    private var toastView: some View {
        Group {
            Text(store.errorMessage ?? "Unknown Error")
                .foregroundColor(Theme.errorText)
                .padding()
                .background(Theme.errorBackground)
                .shadow(radius: 5)
        }
        .cornerRadius(8)
        .padding(.bottom, 50)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(1)
    }
}

