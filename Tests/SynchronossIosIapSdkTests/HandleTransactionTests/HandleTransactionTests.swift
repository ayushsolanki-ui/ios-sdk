import XCTest
import StoreKit
import Foundation
@testable import SynchronossIosIapSdk

@MainActor
final class HandleTransactionTests: XCTestCase {
    
    // MARK: - Properties
    var mockSession: URLSession!
    var appService: AppService!
    var paymentStore: PaymentStore!
    let userId = "testUser"
    let apiKey = "testApiKey"
    
    // MARK: - Setup and Teardown
    override func setUp() async throws {
//        try await super.setUp()
        MockURLProtocol.requestHandler = nil
        mockSession = MockHelpers.makeMockSession()
        appService = AppService(session: mockSession)
        paymentStore = PaymentStore(userId: userId, apiKey: apiKey)
        paymentStore.setAppService(appService)
    }
    
    override func tearDown() async throws {
        mockSession = nil
        appService = nil
        paymentStore = nil
        MockURLProtocol.requestHandler = nil
//        try await super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// 1. Valid receipt: API returns code 200 with valid subscription data.
    func testHandleTransaction_WithValidReceipt_ShouldSetPurchasedSubscription() async throws {
        // Arrange
        let receipt = "valid_receipt"
        
        let serverProduct = ServerProduct(
            productId: "sub_123",
            displayName: "Premium Subscription",
            description: "Access to all premium features.",
            price: 9.99,
            displayPrice: "$9.99",
            recurringPeriodCode: .custom(value: 1, unit: .year),
            productType: "subscription"
        )
        
        let userSubscription = UserSubscriptionDetails(
            product: serverProduct,
            vendorName: "VendorX",
            appName: "AppX",
            appPlatformID: "platform_001",
            platform: "iOS",
            partnerUserId: "partner_123",
            startDate: Int(Date().timeIntervalSince1970),
            endDate: Int(Date().addingTimeInterval(365 * 24 * 60 * 60).timeIntervalSince1970), // +1 year
            status: "active",
            type: "auto-renewable"
        )
        
        let mockResponse = BaseResponse(
            code: 200,
            title: "Success",
            message: "Transaction successful",
            data: userSubscription
        )
        let responseData = try JSONEncoder().encode(mockResponse)
        
        // Set up MockURLProtocol to return the mock response
        MockURLProtocol.requestHandler = { request in
            // Verify the request details if necessary
            XCTAssertEqual(request.url?.path, "/api/iap/ios/handle", "API endpoint path should match")
            XCTAssertEqual(request.httpMethod, "POST", "HTTP method should be POST")
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, responseData)
        }
        
        // Setup serverProducts in PaymentStore
        paymentStore.serverProducts = [serverProduct]
        
        // Act
        await paymentStore.handleTransaction(receipt, nil)
        
        // Assert
        XCTAssertFalse(paymentStore.isPurchaseInProgress, "isPurchaseInProgress should be false after transaction")
        XCTAssertNotNil(paymentStore.purchasedSubscription, "Purchased subscription should be set")
        XCTAssertEqual(paymentStore.purchasedSubscription?.id, "sub_123", "Purchased subscription ID should match")
        XCTAssertNil(paymentStore.selectedProduct, "selectedProduct should be nil after successful transaction")
        XCTAssertNil(paymentStore.error, "No error should be set on successful transaction")
    }
    
    /// 2. Invalid receipt: API returns non-200 code with error message.
    func testHandleTransaction_WithInvalidReceipt_ShouldSetError() async throws {
        // Arrange
        let receipt = "invalid_receipt"
        
        let mockResponse = BaseResponse<UserSubscriptionDetails>(
            code: 400,
            title: "Invalid Receipt",
            message: "The receipt is invalid.",
            data: nil
        )
        let responseData = try JSONEncoder().encode(mockResponse)
        
        // Set up MockURLProtocol to return the mock error response
        MockURLProtocol.requestHandler = { request in
            // Verify the request details if necessary
            XCTAssertEqual(request.url?.path, "/api/iap/ios/handle", "API endpoint path should match")
            XCTAssertEqual(request.httpMethod, "POST", "HTTP method should be POST")
            return (HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!, responseData)
        }
        
        // Act
        await paymentStore.handleTransaction(receipt, nil)
        
        // Assert
        XCTAssertFalse(paymentStore.isPurchaseInProgress, "isPurchaseInProgress should be false after transaction")
        XCTAssertNil(paymentStore.purchasedSubscription, "Purchased subscription should not be set on error")
        XCTAssertNotNil(paymentStore.error, "Error should be set when API returns non-200 code")
        XCTAssertEqual(paymentStore.error?.title, "Error", "Error title should match the API response")
        XCTAssertEqual(paymentStore.error?.message, "The receipt is invalid.", "Error message should match the API response")
    }
}
