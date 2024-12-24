import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20) {
                ForEach(store.tabIndex == 0 ? store.monthlyProducts : store.yearlyProducts) { product in
                    ProductListItemView(product: product)
                        .onTapGesture {
                            if !Helpers.isProductPurchased(with: product.productId, from: store.purchasedSubscriptions) {
                                store.selectedProduct = product
                            }
                        }
                }
            }
        }
    }
}

