//
//  WalletPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit

class WalletPresenter : NSObject {
    var walletInteractor : WalletInteractorInput?
    var walletWireframe : WalletWireframe?
    var pinUserInterface : PINViewInterface?
    var passPharseUserInterface : PassPhraseViewInterface?
    var walletModuleDelegate : WalletModuleDelegate?
    var pinModuleDelegate: PinModuleDelegate?
    
    func handleEndingWalletFlow() {
        print("WalletPresenter - Handle ending wallet flow")
        walletModuleDelegate?.walletModuleDidFinish()
    }
}

extension WalletPresenter: WalletModuleInterface {
    func processInitialWalletInterface() {
        print("WalletPresenter - Process Initial Wallet Interface")
        walletInteractor?.checkLocalWalletExisting()
    }
    
    func enterPIN(pin: String) {
        pinUserInterface?.showConfirmPIN()
    }
    
    func verifyPIN(pin: String) {
        pinUserInterface?.displaySpinner()
        walletInteractor?.verifyPIN(pin: pin)
    }
    
    func manageWallet(passPhrase: String?, pin: String) {
        walletInteractor?.manageWallet(passPhrase, pin: pin)
    }
    
    func verifyConfirmPIN(pin: String, confirmPin: String) {
        self.walletInteractor?.verifyConfirmPIN(pin: pin, confirmPin: confirmPin)
    }
    
    func generateMnemonics() {
        walletInteractor?.generateMnemonics()
    }
    
    func skipShowPassPharse(passPharse: String) {
        walletWireframe?.presentPINInterface(passPharse: passPharse)
    }
}

extension WalletPresenter: WalletInteractorOutput {
    func errorWhileManageWallet(connectionError: ConnectionError, showTryAgain: Bool = false) {
        if connectionError.isApiError, let apiError = connectionError.apiError {
            switch apiError {
                case .SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED,
                     .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD,
                     .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET_ADDRESS:
                    pinUserInterface?.displayErrorAndLogout(apiError)
                default:
                    pinUserInterface?.displayError(apiError.description)
            }
        } else {
            pinUserInterface?.displayTryAgain(connectionError)
        }
    }
    
    func updatedWallet() {
        print("WalletPresenter - Updated wallet")
        // New wallet
        handleEndingWalletFlow()
    }
    
    func finishedCheckServer(result: Bool) {
        print("WalletPresenter - Finished check server wallet, result: \(result)")
        if result {
            walletWireframe?.presentPINInterface(passPharse: nil)
        } else {
            walletWireframe?.presentPassPhraseInterface()
        }
    }
    
    func finishedCheckLocal(result: Bool) {
        print("WalletPresenter - Finished check local wallet, result \(result)")
        if result {
            // Existing wallet
            handleEndingWalletFlow()
        } else {
            walletInteractor?.checkServerWalletExisting()
        }
    }
    
    func verifiedPIN(_ pin: String, result: Bool, needManagedWallet: Bool) {
        if result {
            if needManagedWallet {
                // New wallet
                pinUserInterface?.showCreatingInterface()
            } else {
                walletWireframe?.dismissWalletInterface()
                // Delegate
                pinModuleDelegate?.verifiedPINSuccess(pin)
            }
        } else {
            pinUserInterface?.removeSpinner()
            // Input PIN is NOT correct
            pinUserInterface?.showVerificationFailed()
        }
    }
    
    func generatedMnemonics(mnemonic: String) {
        passPharseUserInterface?.showPassPhrase(passPharse: mnemonic)
    }
}
