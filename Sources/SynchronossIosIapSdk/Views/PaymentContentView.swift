import SwiftUI

struct PaymentContentView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        VStack {
            AppEnvironmentView()
            
            if store.isLoading {
                ProductListSkeleton()
                    .padding()
            } else if store.serverProducts.count != 0 {
                ScrollView(.vertical, showsIndicators: false) {
                    HeaderView()
                        .padding()
                    ProductListView()
                        .padding()
                }
                PurchaseButtonView()
            } else {
                Text("No Products available at this time!")
                    .font(Theme.font(size: 18))
                    .foregroundColor(Theme.textPrimary)
            }
        }
    }
}

