//
//  SettingsModel.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

struct SettingsEntity: Codable, Equatable {
    var name: String
    var enable: Bool = true
}

struct CurrencySettingsEntity: Codable, Equatable {
    let currency: Currency
    var enable: Bool = true
}
