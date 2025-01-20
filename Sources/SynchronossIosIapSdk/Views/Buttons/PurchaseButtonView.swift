import SwiftUI
import StoreKit

/// A view that displays purchase-related buttons and information.
struct PurchaseButtonView: View {
    @EnvironmentObject private var store: PaymentStore

    var body: some View {
        VStack(spacing: 8) {
            recurringText
            purchaseButton
            applyCouponButton
        }
        .padding()
        .background(Theme.actionSecondary)
        .mask(
            RoundedRectangle(cornerRadius: 16)
                .padding(.bottom, -UIScreen.main.bounds.height)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Purchase Options")
    }
}

extension PurchaseButtonView {
    /// Determines the title of the subscribe button based on the subscription state.
    private func subscribeButtonTitle() -> String {
        guard let selectedPlan = store.selectedProduct else { return "Continue" }
        if Helpers.isProductPurchased(selectedPlan.productId, store.purchasedSubscription) {
            return "Subscribed"
        } else {
            return "Continue"
        }
    }
        
    private func isSubscribeButtonDisabled() -> Bool {
        if(store.isPurchaseInProgress) {
            return true
        }
        guard let selectedPlan = store.selectedProduct else { return true }
        return Helpers.isProductPurchased(selectedPlan.productId, store.purchasedSubscription)
    }
    
    /// The text describing the recurring subscription details.
    private var recurringSubscriptionText: String {
        guard let product = store.selectedProduct else { return "" }
        return String(format: LocalizedString.recurringSubscription, product.displayPrice, product.recurringPeriodCode.recurringText)
    }
    
    /// The text view displaying recurring subscription information.
    private var recurringText: some View {
        Text(recurringSubscriptionText)
            .font(Theme.font(size: 12))
            .foregroundColor(Theme.textSecondary)
            .accessibilityLabel(recurringSubscriptionText)
    }
    
    /// The button that initiates the purchase process.
    private var purchaseButton: some View {
        Button(action: {
            initiatePurchase()
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
                        .accessibilityLabel("Purchase in progress")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSubscribeButtonDisabled() ? Theme.primary.opacity(0.4) : Theme.primary)
            .cornerRadius(999)
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .disabled(isSubscribeButtonDisabled())
        .accessibilityLabel(subscribeButtonTitle())
        .accessibilityHint(isSubscribeButtonDisabled() ? LocalizedString.buttonDisabledHint : LocalizedString.purchaseButtonHint)
    }
    
    /// The button that allows users to apply a coupon code.
    private var applyCouponButton: some View {
        Button(action: {
            presentCouponRedemptionSheet()
        }) {
            HStack {
                Text(LocalizedString.applyCoupon)
                    .font(Theme.font(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.actionPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .accessibilityLabel(LocalizedString.applyCoupon)
        .accessibilityHint(LocalizedString.applyCouponHint)
    }
    
    /// Initiates the purchase process for the selected product.
    private func initiatePurchase() {
        guard let selectedPlan = store.selectedProduct else { return }
        Task {
            await store.purchaseProduct(with: selectedPlan)
        }
    }
    
    /// Presents the code redemption sheet for applying coupons.
    private func presentCouponRedemptionSheet() {
        SKPaymentQueue.default().presentCodeRedemptionSheet()
    }
}

// MARK: - Localized Strings
private struct LocalizedString {
    static let continueButton = NSLocalizedString("Continue", comment: "Continue button title")
    static let subscribed = NSLocalizedString("Subscribed", comment: "Subscribed button title")
    static let applyCoupon = NSLocalizedString("Apply Coupon", comment: "Apply coupon button title")
    static let applyCouponHint = NSLocalizedString("Tap to apply a coupon code to your purchase.", comment: "Accessibility hint for apply coupon button")
    static let purchaseButtonHint = NSLocalizedString("Tap to purchase the selected subscription plan.", comment: "Accessibility hint for purchase button")
    static let buttonDisabledHint = NSLocalizedString("Purchase is currently disabled.", comment: "Accessibility hint when purchase button is disabled")
    static let recurringSubscription = NSLocalizedString("Plan auto-renews for %@ %@ until canceled.", comment: "Recurring subscription description with price and period")
    static let restoreFailed = NSLocalizedString("Failed to restore purchases.", comment: "Error message when restoring purchases fails")
}
