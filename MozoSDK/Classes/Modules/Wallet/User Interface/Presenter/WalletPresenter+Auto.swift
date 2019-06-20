//
//  WalletPresenter+Auto.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
extension WalletPresenter {
    func processInitialWalletInterfaceAutomatically(isCreateNew: Bool) {
        if isCreateNew {
            walletInteractorAuto?.createMnemonicAndPinAutomatically()
            return
        }
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
            wallet.encryptSeedPhrase != nil,
            wallet.encryptedPin != nil {
                walletInteractorAuto?.recoverWalletsAutomatically()
        } else {
            processingViewInterface?.displayError(ConnectionError.systemError.errorDescription!)
        }
    }
}
extension WalletPresenter: WalletInteractorAutoOutput {
    func manageWalletAutoSuccessfully() {
        print("WalletPresenter - Manage wallet auto successfully")
        // New wallet
        handleEndingWalletFlow()
    }
    
    func errorWhileManageWalletAutomatically(connectionError: ConnectionError, showTryAgain: Bool) {
        if connectionError.isApiError, let apiError = connectionError.apiError {
            switch apiError {
            case .SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED,
                 .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD,
                 .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET_ADDRESS:
                processingViewInterface?.displayErrorAndLogout(apiError)
                break
            default:
                processingViewInterface?.displayError(apiError.description)
                break
            }
        } else {
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, isEmbedded: false, error: connectionError, delegate: self)
        }
    }
}
extension WalletPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
            wallet.encryptSeedPhrase != nil,
            wallet.encryptedPin != nil {
            walletInteractorAuto?.recoverWalletsAutomatically()
        } else {
            walletInteractorAuto?.createMnemonicAndPinAutomatically()
        }
    }
    
    func didClosePopupWithoutRetry() {
        
    }
}
