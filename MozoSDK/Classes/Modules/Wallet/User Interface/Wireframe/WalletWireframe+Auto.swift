//
//  WalletWireframe+Auto.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
extension WalletWireframe {
    func processInitialWallet(isCreateNew : Bool = false) {
        presentWalletProcessingInterface(isCreateNew: isCreateNew)
        walletPresenter?.processInitialWalletInterfaceAutomatically(isCreateNew: isCreateNew)
    }
    
    func presentWalletProcessingInterface(isCreateNew: Bool) {
        let viewController = viewControllerFromStoryBoard(WalletProcessingViewControllerIdentifier, storyboardName: "Wallet") as! WalletProcessingViewController
        viewController.eventHandler = walletPresenter
        walletPresenter?.processingViewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
}
