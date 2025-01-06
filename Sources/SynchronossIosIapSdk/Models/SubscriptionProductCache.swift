//
//  File.swift
//  SynchronossIosIapSdk
//
//  Created by Monisankar Nath on 06/01/25.
//

import Foundation

struct SubscriptionProductCache: Codable {
    let timeStamp: Int64
    let products: [SubscriptionProduct]
}
