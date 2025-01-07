import SwiftUI

struct ProductListItemView: View {
    @EnvironmentObject var store: PaymentStore
    var product: SubscriptionProduct
    var isSelected: Bool {
        if store.selectedProduct != nil && store.selectedProduct?.productId == product.productId {
            return true
        }
        return false
    }
    
    var isSubscribed: Bool {
        return Helpers.isProductPurchased(with: product.productId, from: store.purchasedSubscription)
    }
    
    var cardBackgroundColor: Color {
        Theme.background
    }
    
    var body: some View {
        VStack {
            if isSubscribed {
                VStack(alignment: .leading) {
                    Text("Current Subscription")
                        .font(Theme.font(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.surfaceOnSurface)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Theme.surfaceBase)
            }
            HStack{
                cardBody
                radioButton
            }
            .padding()
        }
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Theme.primary : Theme.outlineDefault, lineWidth: 1)
        )
    }
}

extension ProductListItemView {
    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(product.priceFormatted)
                .font(Theme.font(size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(product.description)
                .font(Theme.font(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var radioButton: some View {
        // Decide the border color and fill color depending on each state.
        let borderColor: Color
        let fillColor: Color
        
        if isSubscribed {
            // Subscribed State
            borderColor = Theme.surfaceOnSurface
            fillColor = Theme.surfaceOnSurface
        } else if isSelected {
            // Selected State
            borderColor = Theme.outlineVariant
            fillColor = .clear
        } else {
            // Not Selected State
            borderColor = Theme.tertiaryOnTertiary
            fillColor = .clear
        }
        
        return ZStack {
            // Outer circle with stroke and fill
            Circle()
                .stroke(borderColor, lineWidth: 1)
                .background(Circle().fill(fillColor))
                .frame(width: 20, height: 20)
            
            if isSubscribed {
                // Tick in the center for subscribed
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(Theme.font(size: 12))
            } else if isSelected {
                Circle()
                    .fill(Theme.primary)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

