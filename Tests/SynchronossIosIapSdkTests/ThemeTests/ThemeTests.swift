import XCTest
@testable import SynchronossIosIapSdk

@MainActor
final class ThemeTests: XCTestCase {
    
    override func setUp() async throws {
        try clearThemeCache()
    }
    
    override func tearDown() async throws {
        try clearThemeCache()
    }
    
    // MARK: - 1. themConfigTimeStamp in activeUserDetails doesn't match cache => API success => store in cache
    func testHandleCachedTheme_WhenNoMatchingCacheAndApiSucceeds() async throws {
        let timeStamp: Int64 = 9999
        
        let mockThemeData = [
            ServerThemeModel(
                themeName: "light",
                logoUrl: "mock-logo.png",
                primaryColor: "#FFFFFF",
                secondaryColor: "#CCCCCC"
            )
        ]
        let mockResponse = BaseResponse(
            code: 200,
            title: "Success",
            message: "OK",
            data: mockThemeData
        )
        let responseData = try JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, responseData)
        }
        
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        
        paymentStore.activeUserDetails = ActiveUserResponse(
            subscriptionResponseDTO: nil,
            productUpdateTimeStamp: nil,
            themConfigTimeStamp: timeStamp
        )
        
        await paymentStore.handleCachedTheme()
        
        XCTAssertNotNil(paymentStore.vendorThemes, "Expected vendorThemes to be set after success fetch")
        XCTAssertEqual(paymentStore.vendorThemes?.count, 1)
        XCTAssertEqual(paymentStore.vendorThemes?.first?.logoUrl, "mock-logo.png")
        
        XCTAssertNil(paymentStore.error, "Expected no error on success")
        
        let cachedThemes = CacheManager.getCachedTheme(timeStamp)
        XCTAssertEqual(cachedThemes?.count, 1)
        XCTAssertEqual(cachedThemes?.first?.themeName, "light")
    }
    
    // MARK: - 2. both the time stamp matches => pick up cached theme, no network call
    func testHandleCachedTheme_WhenCachedTimestampMatches() async throws {
        let cachedTimestamp: Int64 = 1234
        let cachedTheme = [
            ServerThemeModel(
                themeName: "dark",
                logoUrl: "dark-logo.png",
                primaryColor: "#111111",
                secondaryColor: "#222222"
            )
        ]
        CacheManager.saveThemeCache(ThemeCache(timeStamp: cachedTimestamp, theme: cachedTheme))
        
        MockURLProtocol.requestHandler = { request in
            XCTFail("Should not call the network when cache matches")
            let httpResponse = HTTPURLResponse(url: request.url!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)!
            return (httpResponse, Data())
        }
        
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        paymentStore.activeUserDetails = ActiveUserResponse(
            subscriptionResponseDTO: nil,
            productUpdateTimeStamp: nil,
            themConfigTimeStamp: cachedTimestamp
        )
        
        await paymentStore.handleCachedTheme()
        
        XCTAssertNil(paymentStore.error, "Expected no error when loading from cache")
        XCTAssertNotNil(paymentStore.vendorThemes, "Should have loaded from cache")
        XCTAssertEqual(paymentStore.vendorThemes?.count, 1)
        XCTAssertEqual(paymentStore.vendorThemes?.first?.logoUrl, "dark-logo.png")
    }
    
    // MARK: - 3. activeUserDetails is nil => handleCachedTheme does nothing
    func testHandleCachedTheme_WhenActiveUserDetailsIsNil() async throws {
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        paymentStore.activeUserDetails = nil  // explicitly nil
        
        await paymentStore.handleCachedTheme()
        
        XCTAssertNil(paymentStore.vendorThemes, "Expected vendorThemes to remain nil")
        XCTAssertNil(paymentStore.error, "Expected no error if activeUserDetails is nil")
    }
    
    // MARK: - 4. theme api fails => vendorThemes stays nil, paymentStore.error is set
    func testHandleCachedTheme_WhenApiFails() async throws {
        let errorResponse = BaseResponse<[ServerThemeModel]>(
            code: 500,
            title: "Server Error",
            message: "Something went wrong",
            data: nil
        )
        let responseData = try JSONEncoder().encode(errorResponse)
        
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, responseData)
        }
        
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        paymentStore.activeUserDetails = ActiveUserResponse(
            subscriptionResponseDTO: nil,
            productUpdateTimeStamp: nil,
            themConfigTimeStamp: 5555
        )
        
        await paymentStore.handleCachedTheme()
        
        XCTAssertNotNil(paymentStore.vendorThemes, "Expected vendorThemes not to be nil on error, but rather an empty array.")
        XCTAssertTrue(paymentStore.vendorThemes?.isEmpty ?? false, "Expected vendorThemes to be empty on error.")
        
        XCTAssertNotNil(paymentStore.error, "Expected PaymentStore.error to be set on failure.")
        XCTAssertEqual(paymentStore.error?.title, "Error")
    }
    
    
    // MARK: - Helper: Clear just the theme cache file
    private func clearThemeCache() throws {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let fileURL = cacheURL?.appendingPathComponent("BrandTheme.json")
        if let fileURL = fileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
