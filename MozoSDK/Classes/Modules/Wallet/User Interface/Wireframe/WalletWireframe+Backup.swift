//
//  WalletWireframe+Backup.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
extension WalletWireframe {    
    func presentBackupWalletInterface(mnemonics: String, requestedModule: Module = .Wallet) {
        backupWalletWireframe?.presentBackupWalletInterface(mnemonics: mnemonics, requestedModule: requestedModule)
    }
}
