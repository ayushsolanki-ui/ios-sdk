import XCTest
@testable import SynchronossIosIapSdk

@MainActor
final class ProductsTests: XCTestCase {
    
    override func setUp() async throws {
        // Optional: clear the subscription products cache so each test starts fresh
        try clearProductsCache()
    }
    
    override func tearDown() async throws {
        // Optional: clean up again after the test
        try clearProductsCache()
    }
    
    // MARK: - 1) No matching cache => fetch from API => success => store in cache
    func testHandleCachedProducts_WhenNoMatchingCacheAndApiSucceeds() async throws {
        // 1) No existing products in cache with timestamp 9999
        let productsTimestamp: Int64 = 9999
        
        // 2) Prepare a successful response from the server
        let mockProducts = [
            ServerProduct(
                productId: "iap_monthly_199",
                displayName: "Monthly, $1.99",
                description: "Get 100 GB storage for a Month",
                price: 1.99,
                displayPrice: "$1.99",
                recurringPeriodCode: .custom(value: 1, unit: .month),
                productType: "SUBSCRIPTION"
            ),
            ServerProduct(
                productId: "iap_yearly_999",
                displayName: "Yearly, $9.99",
                description: "Get 100 GB storage for a Year",
                price: 9.99,
                displayPrice: "$9.99",
                recurringPeriodCode: .custom(value: 1, unit: .year),
                productType: "SUBSCRIPTION"
            )
        ]
        let mockResponse = BaseResponse(
            code: 200,
            title: "Success",
            message: "OK",
            data: mockProducts
        )
        let responseData = try JSONEncoder().encode(mockResponse)
        
        // 3) Set up the MockURLProtocol to return that data
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, responseData)
        }
        
        // 4) Create a mock session and an AppService
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        // 5) Create PaymentStore, inject appService, and give it an activeUserDetails with product timestamp
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        paymentStore.activeUserDetails = ActiveUserResponse(
            subscriptionResponseDTO: nil,
            productUpdateTimeStamp: productsTimestamp,
            themConfigTimeStamp: nil
        )
        
        // 6) Call handleCachedProducts()
        await paymentStore.handleCachedProducts()
        
        // 7) Assert: the PaymentStore should now have fetched products
        XCTAssertEqual(paymentStore.serverProducts.count, 2, "Expected 2 products after a successful fetch.")
        XCTAssertNil(paymentStore.error, "Expected no error on success.")
        
        // 8) Check that the new products were saved to cache
        let cached = CacheManager.getCachedProducts(productsTimestamp)
        XCTAssertEqual(cached?.count, 2, "Expected 2 products in the newly saved cache.")
        
        // Optionally, verify specific fields
        XCTAssertEqual(paymentStore.serverProducts.first?.displayName, "Monthly, $1.99")
        XCTAssertEqual(paymentStore.serverProducts.last?.recurringPeriodCode.isYearly, true, "Expected second product to be yearly.")
    }
    
    // MARK: - 2) Matching cache => use cached data => no network call
    func testHandleCachedProducts_WhenCachedTimestampMatches() async throws {
        // 1) We place some products into the cache with timestamp = 1234
        let cachedTimestamp: Int64 = 1234
        let cachedProducts = [
            ServerProduct(
                productId: "cached_prod_abc",
                displayName: "Cached Product ABC",
                description: "Some cached product",
                price: 2.99,
                displayPrice: "$2.99",
                recurringPeriodCode: .custom(value: 2, unit: .week),
                productType: "SUBSCRIPTION"
            )
        ]
        let productsCache = SubscriptionProductsCache(timeStamp: cachedTimestamp, products: cachedProducts)
        CacheManager.saveProductsCache(productsCache)
        
        // 2) We do NOT set up any requestHandler because we expect no network call
        MockURLProtocol.requestHandler = { request in
            XCTFail("handleCachedProducts() should not fetch from network when cache matches.")
            let httpResponse = HTTPURLResponse(url: request.url!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)!
            return (httpResponse, Data())
        }
        
        // 3) Create PaymentStore with the same productUpdateTimeStamp
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        paymentStore.activeUserDetails = ActiveUserResponse(
            subscriptionResponseDTO: nil,
            productUpdateTimeStamp: cachedTimestamp,
            themConfigTimeStamp: nil
        )
        
        // 4) Call handleCachedProducts()
        await paymentStore.handleCachedProducts()
        
        // 5) Assert: it should load from cache
        XCTAssertEqual(paymentStore.serverProducts.count, 1, "Expected 1 product from cache.")
        XCTAssertNil(paymentStore.error, "Expected no error when loading from cache.")
        
        // Validate the loaded product
        let firstProduct = paymentStore.serverProducts.first
        XCTAssertEqual(firstProduct?.productId, "cached_prod_abc")
        XCTAssertEqual(firstProduct?.recurringPeriodCode.isWeekly, true, "Expected a weekly product from cache.")
    }
    
    // MARK: - 3) activeUserDetails is nil => do nothing
    func testHandleCachedProducts_WhenActiveUserDetailsIsNil() async throws {
        // 1) PaymentStore with no activeUserDetails
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        paymentStore.activeUserDetails = nil  // no user details => productUpdateTimeStamp also nil
        
        // 2) Call handleCachedProducts()
        await paymentStore.handleCachedProducts()
        
        // 3) Assert: no products set, no error
        XCTAssertTrue(paymentStore.serverProducts.isEmpty, "Expected serverProducts to remain empty if activeUserDetails is nil.")
        XCTAssertNil(paymentStore.error, "Expected no error if there's nothing to do.")
    }
    
    // MARK: - 4) API fails => serverProducts becomes empty => error is set
    func testHandleCachedProducts_WhenApiFails() async throws {
        // 1) We have no matching cache => must fetch => fails
        let productsTimestamp: Int64 = 5555
        
        // 2) Prepare a failing response
        let errorResponse = BaseResponse<[ServerProduct]>(
            code: 500,
            title: "Server Error",
            message: "Something went wrong",
            data: nil
        )
        let responseData = try JSONEncoder().encode(errorResponse)
        
        // 3) Set up the MockURLProtocol to return that failing response
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(url: request.url!,
                                               statusCode: 500,
                                               httpVersion: nil,
                                               headerFields: nil)!
            return (httpResponse, responseData)
        }
        
        // 4) Create PaymentStore
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        paymentStore.activeUserDetails = ActiveUserResponse(
            subscriptionResponseDTO: nil,
            productUpdateTimeStamp: productsTimestamp,
            themConfigTimeStamp: nil
        )
        
        // 5) Call handleCachedProducts()
        await paymentStore.handleCachedProducts()
        
        // 6) Assert: serverProducts should be empty, error is set
        XCTAssertTrue(paymentStore.serverProducts.isEmpty, "Expected serverProducts to be empty on error.")
        XCTAssertNotNil(paymentStore.error, "Expected PaymentStore.error to be set on failure.")
        
        // Depending on how your code sets error titles, adjust accordingly:
        // If your code sets "Server Error" directly from the response, this will pass.
        // If your code overrides it with "Error", change the assertion.
        XCTAssertEqual(paymentStore.error?.title, "Error")
        XCTAssertEqual(paymentStore.error?.message, "Something went wrong")
        
        // Double-check if "SubscriptionProducts.json" was not saved
        let cached = CacheManager.getCachedProducts(productsTimestamp)
        XCTAssertNil(cached, "Expected no cache file saved on API failure.")
    }
    
    // MARK: - Helper: Clear the Subscription Products Cache
    private func clearProductsCache() throws {
        // Matches the file name in your CacheManager for products: "SubscriptionProducts.json"
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let fileURL = cacheURL?.appendingPathComponent("SubscriptionProducts.json")
        if let fileURL = fileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
