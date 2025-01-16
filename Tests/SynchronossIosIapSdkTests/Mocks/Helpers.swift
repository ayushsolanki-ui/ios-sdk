import Foundation

struct MockHelpers {
    static func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        // This is the key line: we inject our custom protocol
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}
