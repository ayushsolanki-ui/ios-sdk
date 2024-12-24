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
        return Helpers.isProductPurchased(with: product.productId, from: store.purchasedSubscriptions)
    }
    
    var cardBackgroundColor: LinearGradient {
        if isSubscribed {
            return LinearGradient(gradient: Gradient(colors: [Theme.gradientLeft, Theme.gradientRight]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(gradient: Gradient(colors: [.white, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var body: some View {
        HStack{
            cardBody
            if !isSubscribed {
                radioButton
            }
        }
        .padding()
        .background(
            cardBackgroundColor
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: isSelected ? 8 : 0, x: 0, y: isSelected ? 4 : 0)
    }
}

extension ProductListItemView {
    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(product.priceFormatted)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(isSubscribed ? .white : .primary)
            
            Text(product.description)
                .font(.body)
                .foregroundColor(isSubscribed ? .white : .secondary)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var radioButton: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
                .background(Circle().fill(isSelected ? Color.blue : Color.clear))
                .frame(width: 20, height: 20)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
            }
        }
    }
}
