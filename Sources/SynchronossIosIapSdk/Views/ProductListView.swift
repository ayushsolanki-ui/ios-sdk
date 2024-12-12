import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var store: PaymentStore
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20) {
                ForEach(store.availableProducts) { product in
                    ProductListItemView(product: product)
                        .onTapGesture {
                            store.selectedProduct = product
                        }
                }
            }
        }
    }
}

