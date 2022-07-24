//
//  SettingsTypeEnum.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
enum SettingsTypeEnum: Int, CaseIterable {
    case Currencies = 0
    case Password = 1
    case Pin = 2
    case Backup = 3
    case ChangeLanguages = 4
    case Cache = 5
    
    public var name: String {
        switch self {
        case .Currencies: return "Currencies"
        case .Password: return "Change Password"
        case .Pin: return "Change Security PIN"
        case .Backup: return "Backup Wallet"
        case .ChangeLanguages: return "Change Languages"
        case .Cache: return "Clear Cache"
        }
    }
    
    public var icon: String {
        switch self {
        case .Currencies: return "ic_currencies"
        case .Password: return "ic_change_password"
        case .Pin: return "ic_change_pin"
        case .Backup: return "ic_back_up"
        case .ChangeLanguages: return "ic_language"
        case .Cache: return "ic_clear_cache"
        }
    }
}
