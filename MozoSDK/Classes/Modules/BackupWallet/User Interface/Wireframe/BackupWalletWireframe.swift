//
//  BackupWalletWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class BackupWalletWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var presenter: BackupWalletPresenter?
    
    func processBackup() {
        presenter?.checkRememberPIN()
    }
    
    func presentBackupWalletInterface(mnemonics: String, requestedModule: Module = .Wallet) {
        let viewController = viewControllerFromStoryBoard(BackupWalletViewControllerIdentifier, storyboardName: Module.BackupWallet.value) as! BackupWalletViewController
        viewController.eventHandler = presenter
        presenter?.requestedModule = requestedModule
        viewController.mnemonics = mnemonics
        presenter?.viewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentBackupWalletSuccessInterface() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
        let viewController = viewControllerFromStoryBoard(BackupWalletSuccessViewControllerIdentifier, storyboardName: Module.BackupWallet.value) as! BackupWalletSuccessViewController
        viewController.eventHandler = presenter
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentPINInterface() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = presenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.BackupWallet)
    }
    
    func presentPassPhraseInterface(mnemonics: String) {
        walletWireframe?.presentPassPhraseInterface(mnemonics: mnemonics, requestedModule: .BackupWallet)
    }
}
