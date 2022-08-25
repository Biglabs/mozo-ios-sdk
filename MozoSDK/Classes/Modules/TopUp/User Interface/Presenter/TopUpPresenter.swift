//
//  TopUpPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
enum TopUpActionEnum {
    case LoadTokenInfo
    case LoadTopUpAddress
    case TopUpTransfer
}
class TopUpPresenter: NSObject {
    var wireframe: TopUpWireframe?
    var interactor: TopUpInteractorInput?
    var topUpDelegate: TopUpDelegate?
    var transferViewInterface: TopUpTransferViewInterface?
    
    var retryOnAction: TopUpActionEnum?
    
    var isLoadingTokenInfo = true
    var isLoadingTopUpAddress = true
    
    var topUpAddress: String?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveMaintenanceHealthy(_:)), name: .didMaintenanceComplete, object: nil)
    }
    
    @objc func onDidReceiveMaintenanceHealthy(_ notification: Notification) {
        print("TopUpPresenter - On did maintenance back to healthy")
        if DisplayUtils.getTopViewController() is TopUpTransferViewController {
            loadAllData()
        }
    }
    
    func loadAllData() {
        loadTokenInfo()
        if topUpAddress == nil {
            loadTopUpAddress()
        }
    }
    
    func removeSpinner() {
        if isLoadingTopUpAddress || isLoadingTokenInfo {
            return
        }
        transferViewInterface?.removeSpinner()
    }
}
extension TopUpPresenter: TopUpModuleInterface {
    func loadTokenInfo() {
        isLoadingTokenInfo = true
        transferViewInterface?.displaySpinner()
        ModuleDependencies.shared.corePresenter.fetchTokenInfo(callback: {tokenInfo, error in
            if let info = tokenInfo {
                self.didLoadTokenInfo(info)
            } else {
                self.didFailedToLoadTokenInfo(error: (error as? ConnectionError) ?? .unknowError)
            }
        })
    }
    
    func loadTopUpAddress() {
        isLoadingTopUpAddress = true
        transferViewInterface?.displaySpinner()
        interactor?.loadTopUpAddress()
    }
    
    func validateTopUpTransferTransaction(amount: String) {
        interactor?.validateTransferTransaction(amount: amount, topUpAddress: self.topUpAddress)
    }
    
    func requestGetToken() {
        wireframe?.rootWireframe?.closeAllMozoUIs(completion: {
            self.topUpDelegate?.requestGetToken()
        })
    }
    
    func dismiss() {
        wireframe?.dismissModuleInterface()
    }
}
extension TopUpPresenter: TopUpConfirmModuleDelegate {
    func didConfirmTopUpTransaction(_ tx: TransactionDTO) {
        // Current screen is ConfirmTransferViewController
        let viewController = DisplayUtils.getTopViewController() as? ConfirmTransferViewController
        viewController?.displaySpinner()
        interactor?.topUpTransaction(tx, topUpAddress: self.topUpAddress)
    }
}
extension TopUpPresenter: TopUpCompletionModuleDelegate {
    func didTopUpCompleteFailure() {
        wireframe?.presentTopUpFailureInterface()
    }
}
extension TopUpPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        interactor?.sendSignedTopUpTx(pin: pin)
    }
    
    func cancel() {
    }
}
extension TopUpPresenter: TopUpInteractorOutput {
    func validateError(_ error: String) {
        transferViewInterface?.showErrorValidation(error)
    }
    
    func validateSuccessWithTransaction(_ transaction: TransactionDTO) {
        wireframe?.presentConfirmTransferInterface(transaction)
    }
    
    func requestTxCompletion(tx: IntermediaryTransactionDTO, moduleRequest: Module) {
        // Current screen is ConfirmTransferViewController
        let viewController = DisplayUtils.getTopViewController() as? ConfirmTransferViewController
        viewController?.removeSpinner()
        
        ModuleDependencies.shared.corePresenter.fetchTokenInfo(callback: {tokenInfo, _ in
            if let info = tokenInfo {
                let txData = TxDetailDisplayData(transaction: tx, tokenInfo: info)
                self.wireframe?.presentTransactionCompleteInterface(txData.buildDisplayItemFromTransaction(), moduleRequest: moduleRequest)
            }
        })
    }
    
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO) {
        isLoadingTokenInfo = false
        removeSpinner()
        transferViewInterface?.updateUserInterfaceWithTokenInfo(tokenInfo)
    }
    
    func didFailedToLoadTokenInfo(error: ConnectionError) {
        isLoadingTokenInfo = false
        removeSpinner()
        if error == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            return
        }
        retryOnAction = .LoadTokenInfo
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, error: error, delegate: self)
    }
    
    func didLoadTopUpAddress(_ address: String) {
        isLoadingTopUpAddress = false
        removeSpinner()
        self.topUpAddress = address
    }
    
    func didFailedToLoadTopUpAddress(error: ConnectionError) {
        isLoadingTopUpAddress = false
        removeSpinner()
        if error == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            return
        }
        if error == .apiError_STORE_SC_TOPUP_NOT_EXIST {
            return
        }
        retryOnAction = .LoadTopUpAddress
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, error: error, delegate: self)
    }
    
    func failedToPrepareTopUp(error: ConnectionError) {
        // Current screen is ConfirmTransferViewController
        let viewController = DisplayUtils.getTopViewController() as? ConfirmTransferViewController
        viewController?.removeSpinner()
        // Try again here
        retryOnAction = .TopUpTransfer
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: error, delegate: self)
    }
    
    func failedToSignTopUp(error: ConnectionError) {
        // Current screen is ConfirmTransferViewController
        let viewController = DisplayUtils.getTopViewController() as? ConfirmTransferViewController
        viewController?.removeSpinner()
        // Show error here
        viewController?.displayError(ConnectionError.systemError.localizedDescription)
    }
    
    func didSendSignedTopUpFailure(error: ConnectionError) {
        // Current screen is ConfirmTransferViewController
        let viewController = DisplayUtils.getTopViewController() as? ConfirmTransferViewController
        viewController?.removeSpinner()
        // Try again here
        retryOnAction = .TopUpTransfer
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: error, delegate: self)
    }
    
    func requestPINInterface() {
        wireframe?.presentPinInterfaceForMultiSign()
    }
    
    func requestAutoPINInterface() {
        wireframe?.presentAutoPINInterface()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS)) {
            self.wireframe?.rootWireframe?.dismissTopViewController()
        }
    }
}
extension TopUpPresenter: PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        retryOnAction = nil
    }
    
    func didTouchTryAgainButton() {
        if let action = self.retryOnAction {
            switch action {
            case .LoadTokenInfo, .LoadTopUpAddress:
                loadAllData()
                break
            case .TopUpTransfer:
                // Current screen is ConfirmTransferViewController
                let viewController = DisplayUtils.getTopViewController() as? ConfirmTransferViewController
                viewController?.displaySpinner()
                interactor?.requestToRetryTransfer()
                break
            }
        }
    }
}
