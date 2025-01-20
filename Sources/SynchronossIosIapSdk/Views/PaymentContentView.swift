import SwiftUI

/// A view that displays the payment content, including product listings and purchase options.
struct PaymentContentView: View {
    @EnvironmentObject private var store: PaymentStore

    var body: some View {
        VStack {
            AppEnvironmentView()
                .accessibilityHidden(true)
            
            if store.isLoading {
                ProductListSkeleton()
                    .padding()
                    .accessibilityLabel("Loading products")
            } else if !store.serverProducts.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    HeaderView()
                        .padding()
                        .accessibilityHidden(true)
                    ProductListView()
                        .padding()
                }
                PurchaseButtonView()
                    .accessibilityLabel("Purchase Products")
            } else {
                Text(LocalizedString.noProductsAvailable)
                    .font(Theme.font(size: 18))
                    .foregroundColor(Theme.textPrimary)
                    .padding()
                    .accessibilityLabel("No products available at this time")
            }
        }
    }
}

// MARK: - Localized Strings
private struct LocalizedString {
    static let noProductsAvailable = NSLocalizedString("No Products available at this time!", comment: "No products message")
}
