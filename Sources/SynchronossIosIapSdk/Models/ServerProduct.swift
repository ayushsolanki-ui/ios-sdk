import Foundation

struct ServerProduct: Codable, Identifiable {
    var id: String {
        return productId
    }
    let productId: String
    let displayName: String
    let description: String
    let price: Double
    let displayPrice: String
    let recurringPeriodCode: RecurringPeriodCache
    let productType: String
}

enum RecurringPeriodCache: Codable {
    case custom(value: Int, unit: Unit)
    
    enum Unit: String, Codable {
        case day   = "D"
        case week  = "W"
        case month = "M"
        case year  = "Y"
    }
    
    /// Creates a `.custom` case from a raw string like "P1M", "P1W", "P1Y".
    /// Returns `nil` if the format is invalid.
    init?(rawValue: String) {
        // Expecting something like "P1W", "P1M", "P2M", "P1Y", etc.
        guard rawValue.starts(with: "P"), rawValue.count >= 3 else {
            return nil
        }
        
        // Remove the "P" -> e.g. "1W"
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
    
    /// Decodes from something like `"P1W"` or the explicit structure if you want.
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
    
    /// Encodes back to something like "P1W".
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        // Convert .custom(value: 1, unit: .week) -> "P1W"
        switch self {
        case .custom(let value, let unit):
            try container.encode("P\(value)\(unit.rawValue)")
        }
    }
    
    // MARK: - Convenience Checks
    
    var isYearly: Bool {
        if case .custom(_, .year) = self { return true }
        return false
    }
    
    var isMonthly: Bool {
        if case .custom(_, .month) = self { return true }
        return false
    }
    
    var isWeekly: Bool {
        if case .custom(_, .week) = self { return true }
        return false
    }
    
    var isDaily: Bool {
        if case .custom(_, .day) = self { return true }
        return false
    }
    
    // MARK: - Display Helpers (Optional)
    
    var displayText: String {
        switch self {
        case .custom(let value, let unit):
            let unitText: String
            switch unit {
            case .day:   unitText = value > 1 ? "Days"   : "Day"
            case .week:  unitText = value > 1 ? "Weeks"  : "Week"
            case .month: unitText = value > 1 ? "Months" : "Month"
            case .year:  unitText = value > 1 ? "Years"  : "Year"
            }
            return "\(value) \(unitText)"
        }
    }
    
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




