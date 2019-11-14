//
//  TopUpWithdrawWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/19.
//

import Foundation
class TopUpWithdrawWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var presenter: TopUpWithdrawPresenter?
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func requestToWithdrawAndSign(delegate: TopUpWithdrawDelegate) {
        presenter?.delegate = delegate
        presenter?.withdraw()
    }
    
    func presentPinInterface() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = presenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: .Withdraw)
    }
}
