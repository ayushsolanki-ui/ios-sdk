import Foundation

class CacheManager {

    // Where we store the cached data
    private static let fileName = "SubscriptionProducts.json"
    
    /// Returns the file URL in the app's Caches directory.
    private static var cacheFileURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }

    // MARK: - Saving

    /// Saves the subscription cache (products + timestamp) to a JSON file atomically.
    static func saveLocalCache(_ cacheData: SubscriptionProductCache) {
        guard let fileURL = cacheFileURL else { return }
        do {
            let data = try JSONEncoder().encode(cacheData)
            // .atomicWrite ensures the file is fully written or not at all (avoiding partial writes).
            try data.write(to: fileURL, options: .atomicWrite)
        } catch {
            print("Error saving subscription products cache: \(error)")
        }
    }

    // MARK: - Loading

    /// Loads the subscription cache (products + timestamp) from file, if it exists.
    static func loadLocalCache() -> SubscriptionProductCache? {
        guard let fileURL = cacheFileURL,
              FileManager.default.fileExists(atPath: fileURL.path)
        else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(SubscriptionProductCache.self, from: data)
            return decoded
        } catch {
            print("Error loading subscription products cache: \(error)")
            return nil
        }
    }

    // MARK: - Checking Cache

    static func isProductCached(_ latestTimestamp: Int64?) -> Bool {
        guard latestTimestamp != nil else {
            return false
        }
        guard let localCache = loadLocalCache(),
              !localCache.products.isEmpty else {
            return false
        }
        return localCache.timeStamp == latestTimestamp!
    }
}
