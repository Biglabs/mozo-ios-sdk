//
//  AirdropAddWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
class AirdropAddWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var addPresenter: AirdropAddPresenter?
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func requestToAddMoreAndSign(_ event: AirdropEventDTO, delegate: AirdropAddEventDelegate) {
        addPresenter?.delegate = delegate
        addPresenter?.addMoreMozoToEvent(event)
    }
    
    func presentPinInterface() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = addPresenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.Airdrop)
    }
}
