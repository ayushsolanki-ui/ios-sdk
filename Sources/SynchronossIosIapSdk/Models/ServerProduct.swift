import Foundation

// MARK: - ServerProduct Definition

/// Represents a product available for purchase from the server.
struct ServerProduct: Codable, Identifiable {
    /// The unique identifier for the product, conforming to `Identifiable`.
    var id: String { productId }
    let productId: String
    let displayName: String
    let description: String
    let price: Double
    let displayPrice: String
    let recurringPeriodCode: RecurringPeriodCache
    let productType: String
}

// MARK: - RecurringPeriodCache Definition

/// Represents the recurring period of a subscription.
enum RecurringPeriodCache: Codable {
    case custom(value: Int, unit: Unit)
    
    /// Represents the unit of the recurring period.
    enum Unit: String, Codable {
        case day   = "D"
        case week  = "W"
        case month = "M"
        case year  = "Y"
    }
    
    /// The prefix used in raw value strings.
    private static let prefix = "P"
    
    /// Creates a `.custom` case from a raw string like "P1M", "P1W", "P1Y".
    /// Returns `nil` if the format is invalid.
    init?(rawValue: String) {
        // Expecting something like "P1W", "P1M", "P2M", "P1Y", etc.
        guard rawValue.hasPrefix(RecurringPeriodCache.prefix), rawValue.count >= 3 else {
            return nil
        }
        
        // Remove the prefix "P" -> e.g. "1W"
        let periodPart = rawValue.dropFirst()
        
        // Last character should be D/W/M/Y
        guard let lastChar = periodPart.last,
              let unit = Unit(rawValue: String(lastChar)) else {
            return nil
        }
        
        // The numeric portion is everything except the last character
        let numericString = periodPart.dropLast()
        
        guard let value = Int(numericString) else {
            return nil
        }
        
        self = .custom(value: value, unit: unit)
    }
    
    // MARK: - Codable Conformance
    
    /// Decodes from a string like `"P1W"` or the explicit structure if needed.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        
        // Attempt to parse "P1W"-style string
        guard let parsed = RecurringPeriodCache(rawValue: rawString) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unexpected format for RecurringPeriodCache: \(rawString)"
            )
        }
        self = parsed
    }
    
    /// Encodes back to a string like "P1W".
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        // Convert .custom(value: 1, unit: .week) -> "P1W"
        switch self {
        case .custom(let value, let unit):
            try container.encode("\(RecurringPeriodCache.prefix)\(value)\(unit.rawValue)")
        }
    }
    
    // MARK: - Convenience Checks
    
    /// Checks if the recurring period is yearly.
    var isYearly: Bool {
        return hasUnit(.year)
    }
    
    /// Checks if the recurring period is monthly.
    var isMonthly: Bool {
        return hasUnit(.month)
    }
    
    /// Checks if the recurring period is weekly.
    var isWeekly: Bool {
        return hasUnit(.week)
    }
    
    /// Checks if the recurring period is daily.
    var isDaily: Bool {
        return hasUnit(.day)
    }
    
    /// Helper method to check if the recurring period matches the specified unit.
    ///
    /// - Parameter unit: The unit to check against.
    /// - Returns: `true` if the recurring period matches the unit; otherwise, `false`.
    private func hasUnit(_ unit: Unit) -> Bool {
        if case .custom(_, let currentUnit) = self, currentUnit == unit {
            return true
        }
        return false
    }
    
    // MARK: - Display Helpers
    
    /// Provides a user-friendly display text for the recurring period.
    var displayText: String {
        switch self {
        case .custom(let value, let unit):
            let unitText: String
            switch unit {
            case .day:
                unitText = value > 1 ? "Days" : "Day"
            case .week:
                unitText = value > 1 ? "Weeks" : "Week"
            case .month:
                unitText = value > 1 ? "Months" : "Month"
            case .year:
                unitText = value > 1 ? "Years" : "Year"
            }
            return "\(value) \(unitText)"
        }
    }
    
    /// Provides a user-friendly recurring text for the subscription.
    var recurringText: String {
        switch self {
        case .custom(let value, let unit):
            switch unit {
            case .day:
                return value > 1 ? " every \(value) days" : " every day"
            case .week:
                return value > 1 ? " every \(value) weeks" : " every week"
            case .month:
                return value > 1 ? " every \(value) months" : " every month"
            case .year:
                return value > 1 ? " every \(value) years" : " every year"
            }
        }
    }
}
