import SwiftUI

struct PaymentContentView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        VStack {
            AppEnvironmentView()
            
            if store.isLoading {
                ProductListSkeleton()
            } else if store.availableProducts.count != 0 {
                HeaderView()
                ProductListView()
                PurchaseButtonView()
            } else {
                Text("No Products available at this time!")
            }
        }
        .padding()
    }
}

