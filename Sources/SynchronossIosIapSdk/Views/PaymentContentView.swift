import SwiftUI

struct PaymentContentView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        VStack {
            HeaderView()
            if store.isLoading {
                ProgressView("Loading Plans...")
            } else if store.availableProducts.count != 0 {
                ProductListView()
            } else {
                Text("No Products available at this time!")
            }
            PurchaseButtonView()
        }
        .padding()
    }
}

