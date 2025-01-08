import Foundation
import StoreKit

// Product Entity for the SDK and the SERVER
struct SubscriptionProduct: Codable, Identifiable {
    var id: String {
        return productId
    }
    let productId, name, description: String
    let price: Decimal
    let priceFormatted: String
    let kind: SubscriptionKind
    let subscriptionFamilyName, subscriptionFamilyId: String
    let recurringSubscriptionPeriod: RecurringSubscriptionPeriod
    let isFamilyShareable: Bool
    let offers: SubscriptionOffers
    let currencyCode: String
    let icuLocale : String

    static func mapSubscriptionProduct(of product: Product) -> SubscriptionProduct {
        // Map introductory offer
        let introductoryOffer = product.subscription?.introductoryOffer.map { offer in
            Discount(
                modeType: ModeType(rawValue: offer.paymentMode.rawValue) ?? .freeTrial,
                price: "\(offer.price)",
                priceFormatted: offer.displayPrice,
                recurringSubscriptionPeriod: RecurringSubscriptionPeriod(
                    value: offer.period.value,
                    unit: offer.period.unit.toRecurringSubscriptionUnit
                ),
                type: .introOffer,
                numOfPeriods: offer.period.value
            )
        }

        // Map promotional offers
        let promotionalOffers = product.subscription?.promotionalOffers.map { offer in
            Discount(
                modeType: ModeType(rawValue: offer.paymentMode.rawValue) ?? .freeTrial,
                price: "\(offer.price)",
                priceFormatted: offer.displayPrice,
                recurringSubscriptionPeriod: RecurringSubscriptionPeriod(
                    value: offer.period.value,
                    unit: offer.period.unit.toRecurringSubscriptionUnit
                ),
                type: .adhocOffer,
                numOfPeriods: offer.period.value
            )
        } ?? []

        let subscriptionFamilyName = {
            if #available(iOS 16.4, *) {
                return product.subscription?.groupDisplayName ?? ""
            } else {
                return ""
            }
        }()

        return SubscriptionProduct(
            productId: product.id,
            name: product.displayName,
            description: product.description,
            price: product.price,
            priceFormatted: product.displayPrice,
            kind: SubscriptionKind(rawValue: product.type.rawValue) ?? .autoRenewable,
            subscriptionFamilyName: subscriptionFamilyName,
            subscriptionFamilyId: product.subscription?.subscriptionGroupID ?? "",
            recurringSubscriptionPeriod: RecurringSubscriptionPeriod(
                value: product.subscription?.subscriptionPeriod.value ?? 1,
                unit: product.subscription?.subscriptionPeriod.unit.toRecurringSubscriptionUnit ?? .day
            ),
            isFamilyShareable: product.isFamilyShareable,
            offers: SubscriptionOffers(
                introductoryOffer: introductoryOffer,
                promotionalOffers: promotionalOffers
            ),
            currencyCode: product.priceFormatStyle.locale.currencyCode ?? "",
            icuLocale: product.priceFormatStyle.locale.identifier
        )
    }
    
    static func mapSubscriptionProducts(from products: [Product]) -> [SubscriptionProduct] {
        return products.map { product in
            return mapSubscriptionProduct(of: product)
        }
    }
}

extension Product.SubscriptionPeriod.Unit {
    var toRecurringSubscriptionUnit: RecurringSubscriptionPeriod.Unit {
        switch self {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        case .year: return .year
        @unknown default: return .month // Default fallback
        }
    }
}

struct Discount: Codable {
    let modeType: ModeType
    let price, priceFormatted: String
    let recurringSubscriptionPeriod: RecurringSubscriptionPeriod
    let type: DiscountType
    let numOfPeriods: Int
}

struct SubscriptionOffers: Codable {
    let introductoryOffer: Discount?
    let promotionalOffers: [Discount]
}

enum SubscriptionKind: String, Codable {
    case autoRenewable = "Auto-Renewable Subscription"
    case nonRenewable = "Non-Renewable Subscription"
}

enum RecurringSubscriptionPeriod: Codable {
    case custom(value: Int, unit: Unit)

    enum Unit: String, Codable {
        case day = "D"
        case week = "W"
        case month = "M"
        case year = "Y"
    }

    // Initializer for easy mapping
    init(value: Int, unit: Unit) {
        self = .custom(value: value, unit: unit)
    }
    
    var isYearly: Bool {
        if case .custom(_, .year) = self {
            return true
        }
        return false
    }
    
    var isMonthly: Bool {
        if case .custom(_, .month) = self {
            return true
        }
        return false
    }
    
    var isWeekly: Bool {
        if case .custom(_, .week) = self {
            return true
        }
        return false
    }
    
    // Computed property for display text
    var displayText: String {
        switch self {
        case .custom(let value, let unit):
            let unitText: String
            switch unit {
            case .day: unitText = value > 1 ? "Days" : "Day"
            case .week: unitText = value > 1 ? "Weeks" : "Week"
            case .month: unitText = value > 1 ? "Months" : "Month"
            case .year: unitText = value > 1 ? "Years" : "Year"
            }
            return "\(value) \(unitText)"
        }
    }

    // Computed property for recurring text
    var recurringText: String {
        switch self {
        case .custom(let value, let unit):
            switch unit {
            case .day: return value > 1 ? " every \(value) days" : " every day"
            case .week: return value > 1 ? " every \(value) weeks" : " every week"
            case .month: return value > 1 ? " every \(value) months" : " every month"
            case .year: return value > 1 ? " every \(value) years" : " every year"
            }
        }
    }
}

enum ModeType: String, Codable {
    case freeTrial = "FreeTrial"
    case payUpFront = "PayUpFront"
    case payAsYouGo = "PayAsYouGo"
}

enum DiscountType: String, Codable {
    case introOffer = "IntroOffer"
    case adhocOffer = "AdhocOffer"
}
