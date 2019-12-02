//
//  Constants.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

struct GlobalConstants {
    
    private static let defaults = UserDefaults()
    
    static var isThisNotFirstLaunch: Bool { defaults.bool(forKey: DefaultsKeys.isNotfirstLaunch) }
    
    struct DefaultsKeys {
        static let securityEnabling = "securityEnabling"
        static let isNotfirstLaunch = "firstLaunch"
        static let isFirstLoadFromCloud = "firstLoadFromCloud"
    }
    
    struct CloudDataSource {
        static var isFirstLoad: Bool { defaults.bool(forKey: DefaultsKeys.isFirstLoadFromCloud) }
        static func firstLoadComplete() {
            let generatorComplete = (MainGenerator.generator as? CloudIDGenerator)?.isDownloadComplete ?? true
            let settingsComplete = (MainData.settings as? CloudSettingsDataSource)?.isDownloadComplete ?? true
            let operationsComplete = (MainData.source as? CloudOperationDataSource)?.isDownloadComplete ?? true
            let isComplete = generatorComplete && settingsComplete && operationsComplete
            if isComplete {
                defaults.set(false, forKey: DefaultsKeys.isFirstLoadFromCloud)
                print("isFirstLoad = false")

            }
        }
    }
}
