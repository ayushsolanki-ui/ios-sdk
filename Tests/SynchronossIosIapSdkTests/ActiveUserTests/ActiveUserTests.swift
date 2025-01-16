import XCTest
@testable import SynchronossIosIapSdk

@MainActor
final class ActiveUserTests: XCTestCase {
    func testFetchActiveUserDetails_Success() async throws {
        // 1) Define the response you want to return
        let mockActiveUserResponse = ActiveUserResponse(
            subscriptionResponseDTO: nil,
            productUpdateTimeStamp: 12345,
            themConfigTimeStamp: nil
        )
        let mockResponse = BaseResponse(
            code: 200,
            title: "Success",
            message: "Success",
            data: mockActiveUserResponse
        )
        let responseData = try JSONEncoder().encode(mockResponse)
        
        // 2) Set up the requestHandler so it always returns that encoded JSON
        MockURLProtocol.requestHandler = { request in
            // You can check request.url or request.httpMethod if needed
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, responseData)
        }
        
        // 3) Create your real AppService with the mocked session
        let mockSession = MockHelpers.makeMockSession()
        let appService = AppService(session: mockSession)
        
        // 4) Create the PaymentStore that uses the real (but injection-friendly) AppService
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)  // Or however you inject it
        
        // 5) Call the async method
        await paymentStore.fetchActiveUserDetails()
        
        // 6) Assert
        XCTAssertEqual(paymentStore.activeUserDetails?.productUpdateTimeStamp, 12345)
    }
    
    
    func testFetchActiveUserDetails_Failure() async throws {
        // 1. Define a failing response payload (e.g., 404 or 500)
        let errorResponse = BaseResponse<ActiveUserResponse>(
            code: 404,
            title: "Error",
            message: "Resource Not Found",
            data: nil
        )
        let responseData = try JSONEncoder().encode(errorResponse)
        
        // 2. Set up the MockURLProtocol to return that failing response
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, responseData)
        }
        
        // 3. Create a session that uses MockURLProtocol
        let mockSession = MockHelpers.makeMockSession()
        
        // 4. Use the "real" AppService with our mock session
        let appService = AppService(session: mockSession)
        
        // 5. Create PaymentStore and inject the real-but-mocked AppService
        let paymentStore = PaymentStore(userId: "testUser", apiKey: "testApiKey")
        paymentStore.setAppService(appService)
        
        // 6. Perform the call
        await paymentStore.fetchActiveUserDetails()
        
        // 7. Assert that an error is set
        XCTAssertNotNil(paymentStore.error, "Expected an error to be set on PaymentStore")
        XCTAssertEqual(paymentStore.error?.title, "Error")
        XCTAssertEqual(paymentStore.error?.message, "Resource Not Found")
        
        // Optionally ensure no valid data was saved:
        XCTAssertNil(paymentStore.activeUserDetails, "Active user details should be nil on error")
    }
    
}
