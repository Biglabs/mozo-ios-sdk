//
//  WithdrawWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/20/19.
//

import Foundation
class WithdrawWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var withdrawPresenter: WithdrawPresenter?
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func requestToWithdrawAndSign(_ eventId: Int64, delegate: WithdrawAirdropEventDelegate) {
        withdrawPresenter?.delegate = delegate
        withdrawPresenter?.withdrawMozoFromEventId(eventId)
    }
    
    func presentPinInterface() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = withdrawPresenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.Withdraw)
    }
}
