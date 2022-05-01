//
//  BackupWalletModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
protocol BackupWalletModuleInterface {
    func verifyPassPhrases(_ passPhrases: String)
    func completeBackupWallet()
}
