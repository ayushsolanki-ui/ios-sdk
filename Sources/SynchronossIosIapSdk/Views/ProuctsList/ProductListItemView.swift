import SwiftUI

/// A view that represents a single product item in the product list.
struct ProductListItemView: View {
    @EnvironmentObject private var store: PaymentStore
    @Environment(\.colorScheme) private var colorScheme
    let product: ServerProduct
    
    /// Indicates whether the current product is selected.
    private var isSelected: Bool {
        return store.selectedProduct?.productId == product.productId
    }
    
    /// Indicates whether the current product is subscribed.
    private var isSubscribed: Bool {
        return Helpers.isProductPurchased(product.productId, store.purchasedSubscription)
    }
    
    var body: some View {
        VStack {
            if isSubscribed {
                subscriptionBanner
            }
            HStack {
                cardBody
                radioButton
            }
            .padding()
        }
        .background(Theme.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Theme.primary : Theme.textSecondary, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(product.displayPrice)
        .accessibilityHint(isSubscribed ? "Currently subscribed" : "Double tap to select this product")
    }
}

extension ProductListItemView {
    /// A banner indicating the current subscription status.
    private var subscriptionBanner: some View {
        VStack(alignment: .leading) {
            Text("Current Subscription")
                .font(Theme.font(size: 12))
                .fontWeight(.semibold)
                .foregroundColor(Theme.successPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Theme.successSecondary)
        .accessibilityHidden(true)
    }
    
    /// The main body of the product card displaying price and description.
    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(product.displayPrice)
                .font(Theme.font(size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)
            
            Text(product.description)
                .font(Theme.font(size: 14))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// A custom radio button indicating selection or subscription status.
    private var radioButton: some View {
        // Determine the border and fill colors based on the state.
        let borderColor: Color
        let fillColor: Color
        
        if isSubscribed {
            // Subscribed State
            borderColor = Theme.successPrimary
            fillColor = Theme.successPrimary
        } else if isSelected {
            // Selected State
            borderColor = Theme.primary
            fillColor = Theme.background
        } else {
            // Not Selected State
            borderColor = Theme.textSecondary
            fillColor = Theme.background
        }
        
        return ZStack {
            // Outer circle with stroke and fill
            Circle()
                .stroke(borderColor, lineWidth: 1)
                .background(Circle().fill(fillColor))
                .frame(width: 20, height: 20)
                .accessibilityHidden(true)
            
            if isSubscribed {
                // Tick in the center for subscribed
                Image(systemName: "checkmark")
                    .foregroundColor(Theme.background)
                    .font(Theme.font(size: 12))
                    .accessibilityHidden(true)
            } else if isSelected {
                // Inner filled circle for selected state
                Circle()
                    .fill(Theme.primary)
                    .frame(width: 12, height: 12)
                    .accessibilityHidden(true)
            }
        }
    }
}
