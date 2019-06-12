//
//  SettingsPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class SettingsPresenter: NSObject {
    
}
extension SettingsPresenter: SettingsModuleInterface {
    func selectSettingsTab(_ tab: SettingsTypeEnum) {
        switch tab {
        case .Currencies, .Password:
            DisplayUtils.displayUnderConstructionPopup()
            break
        case .Pin:
            MozoSDK.requestForChangePin()
            break
        case .Backup:
            MozoSDK.requestForBackUpWallet()
            break
        }
    }
}
