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
        presenter?.processChangePIN()
    }
    
    func presentChangePINSuccessInterface() {
        rootWireframe?.dismissTopViewController()
        let viewController = viewControllerFromStoryBoard(ChangePINSuccessViewControllerIdentifier, storyboardName: Module.ChangePIN.value) as! ChangePINSuccessViewController
        viewController.eventHandler = presenter
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentChangePINProcessInterface() {
        let viewController = viewControllerFromStoryBoard(ChangePINProcessViewControllerIdentifier, storyboardName: Module.ChangePIN.value) as! ChangePINProcessViewController
        viewController.eventHandler = presenter
        rootWireframe?.displayViewController(viewController)
    }
}
