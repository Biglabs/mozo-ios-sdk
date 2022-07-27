//
//  ChangePINWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var presenter: ChangePINPresenter?
    
    func processChangePIN() {
        presentChangePINProcessInterface()
        presenter?.checkRememberPIN()
    }
    
    func presentChangePINSuccessInterface() {
        let vc = viewControllerFromStoryBoard(ChangePINSuccessViewControllerIdentifier, storyboardName: Module.ChangePIN.value) as! ChangePINSuccessViewController
        rootWireframe?.displayViewController(vc)
    }
    
    func presentChangePINProcessInterface() {
        let vc = viewControllerFromStoryBoard(ChangePINProcessViewControllerIdentifier, storyboardName: Module.ChangePIN.value) as! ChangePINProcessViewController
        presenter?.processInterface = vc
        rootWireframe?.displayViewController(vc)
    }
    
    func presentPINInterface(enterNewPINToChangePIN: Bool = false) {
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: .ChangePIN, enterNewPINToChangePIN: enterNewPINToChangePIN)
    }
}
