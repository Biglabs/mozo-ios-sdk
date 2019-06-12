//
//  BackupWalletWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class BackupWalletWireframe: MozoWireframe {
    var presenter: BackupWalletPresenter?
    
    func presentBackupWalletInterface() {
        let viewController = viewControllerFromStoryBoard(BackupWalletViewControllerIdentifier, storyboardName: "BackupWallet") as! BackupWalletViewController
        viewController.eventHandler = presenter
        presenter?.viewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentBackupWalletSuccessInterface() {
        let viewController = viewControllerFromStoryBoard(BackupWalletSuccessViewControllerIdentifier, storyboardName: "BackupWallet") as! BackupWalletSuccessViewController
        viewController.eventHandler = presenter
        rootWireframe?.displayViewController(viewController)
    }
    
    func dismissBackupWalletInterface() {
        let coreEventHandler = rootWireframe?.mozoNavigationController.coreEventHandler
        coreEventHandler?.requestForCloseAllMozoUIs()
    }
}
