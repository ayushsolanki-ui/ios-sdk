import XCTest
@testable import SynchronossIosIapSdk

@MainActor
final class ViewTests: XCTestCase {
    func testRootPaymentView() {
        let view = RootPaymentView(userId: "testUser", apiKey: "testKey")
        XCTAssertNotNil(view)
    }
    func testPaymentContentView() {
        let view = PaymentContentView()
        XCTAssertNotNil(view)
    }
    func testErrorView() {
        let view = ErrorView()
        XCTAssertNotNil(view)
    }
    func testAppEnvironment() {
        let view = AppEnvironmentView()
        XCTAssertNotNil(view)
    }
    func testProductList() {
        let view = ProductListView()
        XCTAssertNotNil(view)
    }
    func testProductListSkeleton() {
        let view = ProductListSkeleton()
        XCTAssertNotNil(view)
    }
    func testProductListItem() {
        let serverProduct = ServerProduct(
            productId: "iap_monthly_199",
            displayName: "Monthly, $1.99",
            description: "Get 100 GB storage for a Month",
            price: 1.99,
            displayPrice: "$1.99",
            recurringPeriodCode: .custom(value: 1, unit: .month),
            productType: "SUBSCRIPTION"
        )
        let view = ProductListItemView(product: serverProduct)
        XCTAssertNotNil(view)
    }
    func testHeaderView() {
        let view = HeaderView()
        XCTAssertNotNil(view)
    }
    func testTabSwitch() {
        let view = TabSwitcherView()
        XCTAssertNotNil(view)
    }
    func testButtons() {
        let view = PurchaseButtonView()
        XCTAssertNotNil(view)
    }
}
