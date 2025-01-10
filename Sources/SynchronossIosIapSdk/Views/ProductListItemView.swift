import SwiftUI

struct ProductListItemView: View {
    @EnvironmentObject var store: PaymentStore
    @Environment(\.colorScheme) var colorScheme
    var product: ServerProduct
    var isSelected: Bool {
        if store.selectedProduct != nil && store.selectedProduct?.productId == product.productId {
            return true
        }
        return false
    }
    
    var isSubscribed: Bool {
        return Helpers.isProductPurchased(with: product.productId, from: store.purchasedSubscription)
    }
    
    var body: some View {
        VStack {
            if isSubscribed {
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
            }
            HStack{
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
    }
}

extension ProductListItemView {
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
    
    private var radioButton: some View {
        // Decide the border color and fill color depending on each state.
        let borderColor: Color
        let fillColor: Color
        
        if isSubscribed {
            // Subscribed State
            borderColor = Theme.textSecondary
            fillColor = Theme.background
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
            
            if isSubscribed {
                // Tick in the center for subscribed
                Image(systemName: "checkmark")
                    .foregroundColor(Theme.background)
                    .font(Theme.font(size: 12))
            } else if isSelected {
                Circle()
                    .fill(Theme.primary)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

