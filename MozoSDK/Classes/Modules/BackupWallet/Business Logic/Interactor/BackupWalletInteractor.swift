//
//  BackupWalletInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class BackupWalletInteractor: NSObject {
    var output: BackupWalletInteractorOutput?
    
    func checkRandomPassPhrase(_ passPhrases: String, indexs: [Int], originalPassPhrases: String) {
        let ppArray = passPhrases.components(separatedBy: " ")
        if ppArray.count != indexs.count {
            output?.verifyFailed()
            return
        }
        let originalArray = originalPassPhrases.components(separatedBy: " ")
        for (index, item) in indexs.enumerated() {
            if originalArray[item - 1] != ppArray[index] {
                output?.verifyFailed()
                return
            }
        }
        output?.verifySuccess(passPhrase: originalPassPhrases)
    }
}
extension BackupWalletInteractor: BackupWalletInteractorInput {
    func verifyPassPhrases(_ passPhrases: String, indexs: [Int], originalPassPhrases: String) {
        checkRandomPassPhrase(passPhrases, indexs: indexs, originalPassPhrases: originalPassPhrases)
    }
}
