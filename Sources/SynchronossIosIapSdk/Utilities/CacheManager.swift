import Foundation

/// A utility enum providing common caching functions for subscription products and themes.
class CacheManager {
    private static let productsFileName = "SubscriptionProducts.json"
    private static let themeFileName = "BrandTheme.json"
    
    /// Returns the file URL for the given file name in the caches directory.
    ///
    /// - Parameter fileName: The name of the cache file.
    /// - Returns: The URL of the cache file if it exists; otherwise, `nil`.
    private static func cacheFileURL(_ fileName: String) -> URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }
    
    /// Saves cache data to a specified file.
    ///
    /// - Parameters:
    ///   - cacheData: The cache data to save.
    ///   - fileName: The name of the file to save the cache data.
    private static func saveCache<T: Codable>(_ cacheData: T, to fileName: String) {
        guard let fileURL = cacheFileURL(fileName) else { return }
        do {
            let data = try JSONEncoder().encode(cacheData)
            try data.write(to: fileURL, options: .atomicWrite)
        } catch {
            NSLog("Error saving cache for \(fileName): \(error)")
        }
    }
    
    /// Loads cache data from a specified file.
    ///
    /// - Parameter fileName: The name of the file to load the cache data from.
    /// - Returns: The loaded cache data if available; otherwise, `nil`.
    private static func loadCache<T: Codable>(from fileName: String) -> T? {
        guard let fileURL = cacheFileURL(fileName),
              FileManager.default.fileExists(atPath: fileURL.path)
        else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            NSLog("Error loading cache for \(fileName): \(error)")
            return nil
        }
    }
    
    /// Saves subscription products cache data to the cache file.
    ///
    /// - Parameter cacheData: The subscription products cache data to save.
    static func saveProductsCache(_ cacheData: SubscriptionProductsCache) {
        saveCache(cacheData, to: productsFileName)
    }
    
    /// Saves theme cache data to the cache file.
    ///
    /// - Parameter cacheData: The theme cache data to save.
    static func saveThemeCache(_ cacheData: ThemeCache) {
        saveCache(cacheData, to: themeFileName)
    }
    
    /// Loads subscription products cache data from the cache file.
    ///
    /// - Returns: The loaded subscription products cache data if available; otherwise, `nil`.
    static func loadProductsCache() -> SubscriptionProductsCache? {
        loadCache(from: productsFileName)
    }
    
    /// Loads theme cache data from the cache file.
    ///
    /// - Returns: The loaded theme cache data if available; otherwise, `nil`.
    static func loadThemeCache() -> ThemeCache? {
        loadCache(from: themeFileName)
    }
    
    /// Retrieves cached subscription products if the latest timestamp matches.
    ///
    /// - Parameter latestTimestamp: The latest timestamp to validate the cache.
    /// - Returns: An array of `ServerProduct` if the cache is valid and available; otherwise, `nil`.
    static func getCachedProducts(_ latestTimestamp: Int64) -> [ServerProduct]? {
        guard let localCache = loadProductsCache(),
              let timestamp = localCache.timeStamp,
              timestamp == latestTimestamp,
              let products = localCache.products,
              !products.isEmpty
        else {
            return nil
        }
        
        return products
    }
    
    /// Retrieves cached themes if the latest timestamp matches.
    ///
    /// - Parameter latestTimestamp: The latest timestamp to validate the cache.
    /// - Returns: An array of `ServerThemeModel` if the cache is valid and available; otherwise, `nil`.
    static func getCachedTheme(_ latestTimestamp: Int64) -> [ServerThemeModel]? {
        guard let localCache = loadThemeCache(),
              let timestamp = localCache.timeStamp,
              timestamp == latestTimestamp,
              let theme = localCache.theme,
              !theme.isEmpty
        else {
            return nil
        }
        
        return theme
    }
}
