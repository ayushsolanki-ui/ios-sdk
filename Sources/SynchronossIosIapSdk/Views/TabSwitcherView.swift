import SwiftUI

struct TabSwitcherView: View {
    @EnvironmentObject var store: PaymentStore
    
    var body: some View {
        GeometryReader { proxy in
            let tabWidth = proxy.size.width / 2
            
            ZStack(alignment: .leading) {
                staticBackground
                animatedBackground(tabWidth: tabWidth)
                twoTabs
            }
            
            
        }
        .frame(height: 40)
        
    }
}

extension TabSwitcherView {
    private var twoTabs: some View {
        HStack(spacing: 0) {
            Button(action: {
                store.tabIndex = 0
                store.selectedProduct = nil
            }) {
                Text("Monthly")
                    .font(.system(size: 14))
                    .foregroundColor(store.tabIndex == 0 ? .white : Theme.blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Button(action: {
                store.tabIndex = 1
                store.selectedProduct = nil
            }) {
                Text("Yearly")
                    .font(.system(size: 14).weight(.semibold))
                    .foregroundColor(store.tabIndex == 1 ? .white : Theme.blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var staticBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Theme.lightBlue)
            .frame(height: 48)
    }
    
    private func animatedBackground(tabWidth: CGFloat) -> some View {
            // How much space you want between the light and deep blue horizontally:
            let horizontalInset: CGFloat = 4
            
            // The capsule is narrower by twice the inset (left + right).
            let capsuleWidth = tabWidth - (horizontalInset * 2)
            
            return RoundedRectangle(cornerRadius: 8)
            .fill(Theme.blue)
                .frame(width: capsuleWidth, height: 40)
                .offset(x: store.tabIndex == 1
                        ? tabWidth + horizontalInset
                        : horizontalInset)
                .animation(.easeInOut, value: store.tabIndex)
        }
}
