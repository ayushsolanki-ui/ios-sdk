import SwiftUI

struct TabSwitcherView: View {
    @EnvironmentObject var store: PaymentStore

    private let tabs: [String] = ["Monthly", "Weekly", "Yearly"]
    
    var body: some View {
        GeometryReader { proxy in
            let numberOfTabs = CGFloat(tabs.count)
            let tabWidth = proxy.size.width / numberOfTabs
            
            ZStack(alignment: .leading) {
                staticBackground
                animatedBackground(tabWidth: tabWidth)
                tabButtons
            }
        }
        .frame(height: 40)
    }
}

// MARK: - Subviews
extension TabSwitcherView {
    private var tabButtons: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    store.tabIndex = index
                    store.selectedProduct = nil
                }) {
                    Text(tabs[index])
                        .font(Theme.font(size: 14))
                        .foregroundColor(store.tabIndex == index ? .white : Theme.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    private var staticBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Theme.secondary)
            .frame(height: 48)
    }
    
    private func animatedBackground(tabWidth: CGFloat) -> some View {
        // How much horizontal “inset” you want on each side inside the tab
        let horizontalInset: CGFloat = 4
        
        // The capsule is narrower by twice the inset (left + right).
        let capsuleWidth = tabWidth - (horizontalInset * 2)
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(Theme.primary)
            .frame(width: capsuleWidth, height: 40)
        // Move the background according to the currently selected tab
            .offset(x: (CGFloat(store.tabIndex) * tabWidth) + horizontalInset)
            .animation(.easeInOut, value: store.tabIndex)
    }
}
