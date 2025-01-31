import SwiftUI

/// A view that allows users to switch between different subscription tabs.
struct TabSwitcherView: View {
    @EnvironmentObject private var store: PaymentStore

    /// The titles of the available subscription tabs.
    private let tabs: [String] = [
        LocalizedString.monthly,
        LocalizedString.weekly,
        LocalizedString.yearly
    ]
    
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Subscription Tabs")
        .accessibilityHint("Swipe or tap to switch between subscription plans.")
    }
}

// MARK: - Subviews
extension TabSwitcherView {
    /// A horizontal stack of tab buttons.
    private var tabButtons: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                tabButton(for: index)
            }
        }
    }
    
    /// A helper method that returns a button for each tab.
    private func tabButton(for index: Int) -> some View {
        Button(action: {
            onTabTapped(index)
        }) {
            Text(tabs[index])
                .font(Theme.font(size: 14))
                .foregroundColor(store.tabIndex == index ? .white : Theme.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(tabs[index])
                .accessibilityAddTraits(store.tabIndex == index ? .isSelected : [])
                .accessibilityHint("Tap to select the \(tabs[index]) subscription.")
        }
    }
    
    /// Action to handle tab selection.
    private func onTabTapped(_ index: Int) {
        withAnimation(.easeInOut) {
            store.tabIndex = index
            store.selectedProduct = nil
        }
    }
    
    /// The static background behind the tabs.
    private var staticBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Theme.secondary)
            .frame(height: 48)
            .accessibilityHidden(true)
    }
    
    /// The animated background that indicates the selected tab.
    /// - Parameter tabWidth: The width of each tab.
    /// - Returns: A view representing the animated background.
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
            .accessibilityHidden(true)
    }
}

// MARK: - Localized Strings
private struct LocalizedString {
    static let monthly = NSLocalizedString("Monthly", comment: "Monthly subscription tab title")
    static let weekly = NSLocalizedString("Weekly", comment: "Weekly subscription tab title")
    static let yearly = NSLocalizedString("Yearly", comment: "Yearly subscription tab title")
}