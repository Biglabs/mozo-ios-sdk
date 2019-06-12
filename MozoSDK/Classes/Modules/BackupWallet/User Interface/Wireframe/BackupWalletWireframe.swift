//
//  BackupWalletWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class BackupWalletWireframe: MozoWireframe {
    var presenter: BackupWalletPresenter?
    
    func processBackup() {
        
    }
    
    func presentBackupWalletInterface(mnemonics: String, requestedModule: Module = .Wallet) {
        let viewController = viewControllerFromStoryBoard(BackupWalletViewControllerIdentifier, storyboardName: Module.BackupWallet.value) as! BackupWalletViewController
        viewController.eventHandler = presenter
        viewController.mnemonics = mnemonics
        presenter?.viewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentBackupWalletSuccessInterface() {
        let viewController = viewControllerFromStoryBoard(BackupWalletSuccessViewControllerIdentifier, storyboardName: Module.BackupWallet.value) as! BackupWalletSuccessViewController
        viewController.eventHandler = presenter
        rootWireframe?.displayViewController(viewController)
    }
}
