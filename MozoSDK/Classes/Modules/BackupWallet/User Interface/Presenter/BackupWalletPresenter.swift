//
//  BackupWalletPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class BackupWalletPresenter: NSObject {
    var wireframe: BackupWalletWireframe?
    var viewInterface: BackupWalletViewInterface?
    var delegate: BackupWalletModuleDelegate?
    
    var requestedModule: Module = .Wallet
    
    func checkRememberPIN() {
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
            let encryptedMnemonics = wallet.encryptSeedPhrase {
            if let encryptedPin = wallet.encryptedPin, let pinSecret = AccessTokenManager.getPinSecret() {
                let decryptPin = encryptedPin.decrypt(key: pinSecret)
                let mnemonics = encryptedMnemonics.decrypt(key: decryptPin)
                self.displayBackupWallet(mnemonics: mnemonics)
            } else {
                wireframe?.presentPINInterface()
            }
        } else {
            // System error
        }
    }
    
    func displayBackupWallet(mnemonics: String) {
        wireframe?.presentPassPhraseInterface(mnemonics: mnemonics)
    }
    
    func processAfterReceivingPIN(pin: String) {
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
            let encryptedMnemonics = wallet.encryptSeedPhrase {
            let mnemonics = encryptedMnemonics.decrypt(key: pin)
            self.displayBackupWallet(mnemonics: mnemonics)
        } else {
            // System error
        }
    }
}
extension BackupWalletPresenter: BackupWalletModuleInterface {
    func verifyPassPhrases(_ passPhrases: String) {
        if requestedModule == .Wallet {
            delegate?.didFinishCheckPassPhrase(passPhrases)
        } else {
            wireframe?.presentBackupWalletSuccessInterface()
        }
    }
    
    func completeBackupWallet() {
        wireframe?.dismissModuleInterface()
    }
}
extension BackupWalletPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        processAfterReceivingPIN(pin: pin)
    }
    
    func cancel() {
    }
}
