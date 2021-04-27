//
//  CorePresenter+SpeedSelection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
extension CorePresenter: SpeedSelectionModuleDelegate {
    func didSelectAutoWay() {
        coreWireframe?.processWalletAuto(isCreateNew: true)
    }
    
    func didSelectManualWay() {
        coreWireframe?.prepareForWalletInterface()
    }
    
    func didRequestLogoutInternally() {
        coreWireframe?.corePresenter?.requestForCloseAllMozoUIs() {
            self.coreWireframe?.requestForLogout()
        }
    }
}
