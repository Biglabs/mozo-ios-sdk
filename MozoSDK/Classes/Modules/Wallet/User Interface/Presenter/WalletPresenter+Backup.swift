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
}
