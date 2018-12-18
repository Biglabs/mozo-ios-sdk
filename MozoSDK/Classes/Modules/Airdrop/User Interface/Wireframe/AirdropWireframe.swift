//
//  AirdropWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
class AirdropWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var adPresenter: AirdropPresenter?
    
    func presentPinInterfaceForMultiSign() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = adPresenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.Airdrop)
    }
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func requestMultiSign(signature: Signature, delegate: MultiSignDelegate) {
        adPresenter?.multiSignDelegate = delegate
        adPresenter?.requestMultiSign(signature: signature)
    }
    
    func requestCreateAndSignAirdropEvent(_ event: AirdropEventDTO, delegate: AirdropEventDelegate) {
        adPresenter?.airdropEventDelegate = delegate
        adPresenter?.createAirdropEvent(event)
    }
}
