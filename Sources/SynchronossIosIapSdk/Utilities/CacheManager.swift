import Foundation

class CacheManager {
    private static let productsFileName = "SubscriptionProducts.json"
    private static let themeFileName = "BrandTheme.json"
    
    private static func cacheFileURL(_ fileName: String) -> URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }
    
    static func saveProductsCache(_ cacheData: SubscriptionProductsCache) {
        guard let fileURL = cacheFileURL(productsFileName) else { return }
        do {
            let data = try JSONEncoder().encode(cacheData)
            try data.write(to: fileURL, options: .atomicWrite)
        } catch {
            print("Error saving subscription products cache: \(error)")
        }
    }
    
    static func saveThemeCache(_ cacheData: ThemeCache) {
        guard let fileURL = cacheFileURL(themeFileName) else { return }
        do {
            let data = try JSONEncoder().encode(cacheData)
            try data.write(to: fileURL, options: .atomicWrite)
        } catch {
            print("Error saving theme cache: \(error)")
        }
    }
    
    static func loadProductsCache() -> SubscriptionProductsCache? {
        guard let fileURL = cacheFileURL(productsFileName),
              FileManager.default.fileExists(atPath: fileURL.path)
        else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(SubscriptionProductsCache.self, from: data)
            return decoded
        } catch {
            print("Error loading subscription products cache: \(error)")
            return nil
        }
    }
    
    static func loadThemeCache() -> ThemeCache? {
        guard let fileURL = cacheFileURL(themeFileName),
              FileManager.default.fileExists(atPath: fileURL.path)
        else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(ThemeCache.self, from: data)
            return decoded
        } catch {
            print("Error loading theme cache: \(error)")
            return nil
        }
    }
    
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
