//
//  WalletWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit

class WalletWireframe: MozoWireframe {
    var resetPINWireframe: ResetPINWireframe?
    var backupWalletWireframe: BackupWalletWireframe?
    var walletPresenter : WalletPresenter?
    var pinViewController : PINViewController?
    var passPhraseViewController: PassPhraseViewController?
    
    func presentInitialWalletInterface() {
        walletPresenter?.processInitialWalletInterface()
    }
    
    func presentPINInterface(passPharse: String?, requestFrom module: Module = Module.Wallet,
                             recoverFromServerEncryptedPhrase : Bool = false,
                             enterNewPINToChangePIN: Bool = false) {
        let viewController = viewControllerFromStoryBoard(PINViewControllerIdentifier) as! PINViewController
        viewController.eventHandler = walletPresenter
        viewController.passPhrase = passPharse
        viewController.moduleRequested = module
        viewController.enterNewPINToChangePIN = enterNewPINToChangePIN
        viewController.recoverFromServerEncryptedPhrase = recoverFromServerEncryptedPhrase
        
        pinViewController = viewController
        walletPresenter?.pinUserInterface = viewController
        if module == .Airdrop || module == .Withdraw {
            rootWireframe?.showRootViewController(viewController, inWindow: (UIApplication.shared.delegate?.window!)!)
        } else if module == .BackupWallet {
            rootWireframe?.changeRootViewController(viewController)
        } else {
            rootWireframe?.displayViewController(viewController)
        }
    }
    
    func updatePINInterfaceAfterResetPIN() {
        if let topViewController = rootWireframe?.mozoNavigationController.viewControllers.last as? PINViewController {
            pinViewController = topViewController
            pinViewController?.refreshUIsAfterResettingPIN()
            walletPresenter?.pinUserInterface = topViewController
        }
    }
    
    func presentPassPhraseInterface(mnemonics: String? = nil, requestedModule: Module = .Wallet) {
        let viewController = viewControllerFromStoryBoard(PassPhraseViewControllerIdentifier) as! PassPhraseViewController
        viewController.eventHandler = walletPresenter
        viewController.passPharse = mnemonics
        viewController.requestedModule = requestedModule
        passPhraseViewController = viewController
        walletPresenter?.passPharseUserInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentResetPINInterface(requestFrom module: Module = Module.Wallet) {
        resetPINWireframe?.presentResetPINInterface(requestFrom: module)
    }
    
    func dismissWalletInterface() {
        rootWireframe?.dismissTopViewController()
    }
}
