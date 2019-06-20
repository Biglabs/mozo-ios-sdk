//
//  WalletPresenter+Backup.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
extension WalletPresenter: BackupWalletModuleDelegate {
    func didFinishCheckPassPhrase(_ passPhrase: String) {
        walletWireframe?.presentPINInterface(passPharse: passPhrase)
    }
    
    func verifiedCurrentPINToBackup(pin: String, result: Bool) {
        if result {
            pinModuleDelegate?.verifiedPINSuccess(pin)
        } else {
            pinUserInterface?.removeSpinner()
            // Input PIN is NOT correct
            pinUserInterface?.showVerificationFailed()
        }
    }
}
