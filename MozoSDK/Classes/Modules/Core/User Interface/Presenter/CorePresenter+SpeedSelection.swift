//
//  CorePresenter+SpeedSelection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
extension CorePresenter: SpeedSelectionModuleDelegate {
    func didSelectAutoWay() {
        coreWireframe?.processWalletAuto()
    }
    
    func didSelectManualWay() {
        coreWireframe?.prepareForWalletInterface()
    }
}