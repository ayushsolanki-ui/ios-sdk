import SwiftUI

struct PaymentContentView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        VStack {
            AppEnvironmentView()
            
            if store.isLoading {
                ProductListSkeleton()
                    .padding()
            } else if store.availableProducts.count != 0 {
                HeaderView()
                    .padding()
                ProductListView()
                    .padding()
                PurchaseButtonView()
            } else {
                Text("No Products available at this time!")
            }
        }
    }
}

