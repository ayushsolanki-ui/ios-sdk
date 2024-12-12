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
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)
                .shadow(radius: 5)
        }
        .padding(.bottom, 50)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(1)
    }
}

