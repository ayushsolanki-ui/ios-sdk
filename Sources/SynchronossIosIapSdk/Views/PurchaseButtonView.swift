import SwiftUI
import StoreKit

struct PurchaseButtonView: View {
    @EnvironmentObject var store: PaymentStore

    var body: some View {
        VStack(spacing: 8) {
            recurringText
            purchaseButton
            applyCouponButton
        }
        .padding()
        .background(Theme.tertiaryBase)
        .mask(
            RoundedRectangle(cornerRadius: 16)
                .padding(.bottom, -UIScreen.main.bounds.height)
        )
    }
}

extension PurchaseButtonView {
    private func subscribeButtonTitle() -> String {
        guard let selectedPlan = store.selectedProduct else { return "Continue" }
        if Helpers.isProductPurchased(with: selectedPlan.productId, from: store.purchasedSubscription) {
            return "Subscribed"
        } else if store.purchasedSubscription == nil {
            return "Continue"
        } else {
            return "Continue"
        }
    }
        
    private func isSubscribeButtonDisabled() -> Bool {
        if(store.isPurchaseInProgress) {
            return true
        }
        guard let selectedPlan = store.selectedProduct else { return true }
        return Helpers.isProductPurchased(with: selectedPlan.productId, from: store.purchasedSubscription)
    }
    private var recurringSubscriptionText: String {
        if let product = store.selectedProduct {
            return "Plan auto-renews for \(product.priceFormatted)\(product.recurringSubscriptionPeriod.recurringText) until canceled."
        }
        return ""
    }
    private var purchaseButton: some View {
        Button(action: {
            if let selectedPlan = store.selectedProduct {
                Task {
                    await store.purchaseProduct(with: selectedPlan)
                }
            }
        }) {
            HStack {
                Text(subscribeButtonTitle())
                    .font(Theme.font(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                        
                if store.isPurchaseInProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.leading, 8) 
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSubscribeButtonDisabled() ? Color.gray : Theme.primary)
            .cornerRadius(999)
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .disabled(isSubscribeButtonDisabled())

    }
    
    private var applyCouponButton: some View {
        Button(action: {
            SKPaymentQueue.default().presentCodeRedemptionSheet()
        }) {
            HStack {
                Text("Apply Coupon")
                    .font(Theme.font(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.bodyText)
                        
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
    
    private var recurringText: some View {
        Text(recurringSubscriptionText)
            .font(Theme.font(size: 12))
            .foregroundColor(Theme.tertiaryOnTertiary)
    }
}
