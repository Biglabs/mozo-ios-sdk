//
//  BackupWalletPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class BackupWalletPresenter: NSObject {
    var wireframe: BackupWalletWireframe?
    var interactor: BackupWalletInteractorInput?
    var viewInterface: BackupWalletViewInterface?
    var delegate: BackupWalletModuleDelegate?
    
    var requestedModule: Module = .Wallet
}
extension BackupWalletPresenter: BackupWalletModuleInterface {
    func verifyPassPhrases(_ passPhrases: String, indexs: [Int], originalPassPhrases: String) {
        interactor?.verifyPassPhrases(passPhrases, indexs: indexs, originalPassPhrases: originalPassPhrases)
    }
    
    func completeBackupWallet() {
        wireframe?.dismissModuleInterface()
    }
}
extension BackupWalletPresenter: BackupWalletInteractorOutput {
    func verifyFailed() {
        viewInterface?.displayVerifyFailed()
    }
    
    func verifySuccess(passPhrase: String) {
        if requestedModule == .Wallet {
            delegate?.didFinishCheckPassPhrase(passPhrase)
        } else {
            wireframe?.presentBackupWalletSuccessInterface()
        }
    }
}
