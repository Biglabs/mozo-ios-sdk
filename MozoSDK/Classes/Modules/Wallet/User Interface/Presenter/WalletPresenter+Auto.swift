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
            self.displayError(ConnectionError.systemError.errorDescription!)
        }
    }
    
    func registerMaintenanceNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveMaintenanceHealthy(_:)), name: .didMaintenanceComplete, object: nil)
    }
    
    @objc func onDidReceiveMaintenanceHealthy(_ notification: Notification) {
        print("WalletPresenter - On did maintenance back to healthy")
        if let topViewController = DisplayUtils.getTopViewController() {
            if topViewController is WaitingViewController {
                didTouchTryAgainButton()
            } else if topViewController is SpeedSelectionViewController {
                // Do nothing
            }
        }
    }
}
extension WalletPresenter: WalletInteractorAutoOutput {
    func manageWalletAutoSuccessfully() {
        handleEndingWalletFlow()
    }
    
    func errorWhileManageWalletAutomatically(connectionError: ConnectionError, showTryAgain: Bool) {
        if connectionError == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            return
        }
        if connectionError.isApiError, let apiError = connectionError.apiError {
            switch apiError {
            case .SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED,
                 .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD,
                 .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET_ADDRESS:
                self.displayErrorAndLogout(apiError)
                break
            default:
                self.displayError(apiError.description)
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
