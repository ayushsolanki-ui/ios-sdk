import SwiftUI

struct ErrorView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        Group {
            if store.showToast, store.error != nil {
                VStack {
                    Spacer()
                    toastView
                }
                .padding()
            }
        }
    }
}

extension ErrorView {
    private var toastView: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(Theme.errorPrimary)
                .frame(width: 4)
            
            // Main content
            VStack(alignment: .leading, spacing: 4) {
                Text(store.error?.title ?? "Error")
                    .font(Theme.font(size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textSecondary)
                
                Text(store.error?.message ?? "")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.leading, 12)
            .padding(.vertical, 12)
            
            Spacer()
            
            // Close button
            Button(action: {
                store.error = nil
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Theme.textSecondary)
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
        }
        // The key line: fix the vertical size to the content
        .fixedSize(horizontal: false, vertical: true)
        
        .background(Theme.errorSecondary)
        .cornerRadius(8)
        .padding(.bottom, 50)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(1)
    }
}
