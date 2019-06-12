//
//  BackupWalletInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
protocol BackupWalletInteractorInput {
    func verifyPassPhrases(_ passPhrases: String, indexs: [Int], originalPassPhrases: String)
}
protocol BackupWalletInteractorOutput {
    func verifyFailed()
    func verifySuccess(passPhrase: String)
}
