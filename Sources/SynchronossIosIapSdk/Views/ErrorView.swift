import SwiftUI

/// A view that displays error messages as toast notifications.
struct ErrorView: View {
    @EnvironmentObject private var store: PaymentStore

    var body: some View {
        if store.showToast, let error = store.error {
            VStack {
                Spacer()
                toastView(error: error)
            }
            .padding()
        }
    }
}

extension ErrorView {
    /// The toast view displaying the error message.
    /// - Parameter error: The error to display.
    private func toastView(error: ErrorModel) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(Theme.errorPrimary)
                .frame(width: 4)
                .accessibilityHidden(true)
            
            // Main content
            VStack(alignment: .leading, spacing: 4) {
                Text(error.title)
                    .font(Theme.font(size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textSecondary)
                
                Text(error.message)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.leading, 12)
            .padding(.vertical, 12)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(error.title): \(error.message)")
            
            Spacer()
            
            // Close button
            Button(action: {
                store.error = nil
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Theme.textSecondary)
                    .padding()
                    .accessibilityLabel("Close error message")
            }
            .buttonStyle(PlainButtonStyle())
        }
        // Fix the vertical size to the content
        .fixedSize(horizontal: false, vertical: true)
        .background(Theme.errorSecondary)
        .cornerRadius(8)
        .padding(.bottom, 50)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(1)
    }
}
