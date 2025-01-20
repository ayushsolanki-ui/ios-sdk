import SwiftUI

/// A view that displays a list of products based on the selected tab.
struct ProductListView: View {
    @EnvironmentObject private var store: PaymentStore
    
    /// The spacing between each product item in the list.
    private let itemSpacing: CGFloat = 20.0
    
    var body: some View {
        VStack(spacing: itemSpacing) {
            ForEach(currentProducts, id: \.productId) { product in
                ProductListItemView(product: product)
                    .onTapGesture {
                        handleProductTap(product)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(product.displayName)
                    .accessibilityHint("Double tap to select this product.")
            }
        }
    }
    
    /// Determines the list of products to display based on the current tab index.
    private var currentProducts: [ServerProduct] {
        switch store.tabIndex {
        case 0:
            return store.monthlyProducts
        case 1:
            return store.weeklyProducts
        case 2:
            return store.yearlyProducts
        default:
            return []
        }
    }
    
    /// Handles the tap gesture on a product item.
    /// - Parameter product: The product that was tapped.
    private func handleProductTap(_ product: ServerProduct) {
        if !Helpers.isProductPurchased(product.id, store.activeUserDetails?.subscriptionResponseDTO?.product) {
            store.selectedProduct = product
        }
    }
}
