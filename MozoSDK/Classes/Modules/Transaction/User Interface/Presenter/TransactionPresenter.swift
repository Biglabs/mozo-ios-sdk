//
//  TransactionPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

class TransactionPresenter : NSObject {
    var txWireframe : TransactionWireframe?
    var txInteractor: TransactionInteractorInput?
    var transferUserInterface : TransferViewInterface?
    var confirmUserInterface : ConfirmTransferViewInterface?
    var transactionModuleDelegate: TransactionModuleDelegate?
    var topUpModuleDelegate: TopUpConfirmModuleDelegate?
    
    var searchPhoneNo: String?
    
    func updateInterfaceWithDisplayItem(_ displayItem: AddressBookDisplayItem) {
        transferUserInterface?.updateInterfaceWithDisplayItem(displayItem)
    }
}

extension TransactionPresenter: TransactionModuleInterface {
    func requestToRetryTransfer() {
        txInteractor?.requestToRetryTransfer()
    }
    
    func showAddressBookInterface() {
        transactionModuleDelegate?.requestAddressBookInterfaceForTransaction()
    }
    
    func sendConfirmTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO) {
        confirmUserInterface?.displaySpinner()
        txInteractor?.sendUserConfirmTransaction(transaction, tokenInfo: tokenInfo)
    }
    
    func topUpConfirmTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO) {
        topUpModuleDelegate?.didConfirmTopUpTransaction(transaction, tokenInfo: tokenInfo)
    }
    
    func validateTransferTransaction(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?) {
        txInteractor?.validateTransferTransaction(tokenInfo: tokenInfo, toAdress: toAdress, amount: amount, displayContactItem: displayContactItem)
    }
    
    func showScanQRCodeInterface() {
        txWireframe?.presentScannerQRCodeInterface()
    }
    
    func loadTokenInfo() {
        txInteractor?.loadTokenInfo()
    }
}

extension TransactionPresenter: ScannerViewControllerDelegate {
    func didReceiveValueFromScanner(_ value: String) {
        txInteractor?.validateValueFromScanner(value)
    }
}

extension TransactionPresenter : TransactionInteractorOutput {
    func requestAutoPINInterface() {
        txWireframe?.presentAutoPINInterface()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS)) {
            self.txWireframe?.rootWireframe?.dismissTopViewController()
        }
    }
    
    func didReceiveAddressBookDisplayItem(_ item: AddressBookDisplayItem) {
        transferUserInterface?.updateInterfaceWithDisplayItem(item)
    }
    
    func didReceiveAddressfromScanner(_ address: String) {
        transferUserInterface?.updateUserInterfaceWithAddress(address)
    }
    
    func performTransferWithError(_ error: ConnectionError, isTransferScreen: Bool) {
        if let apiError = error.apiError, apiError == .SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS {
            if isTransferScreen {
                transferUserInterface?.displayError(apiError.description)
            } else {
                confirmUserInterface?.removeSpinner()
                confirmUserInterface?.displayError(apiError.description)
            }
        } else {
            if isTransferScreen {
                transferUserInterface?.displayTryAgain(error)
            } else {
                confirmUserInterface?.removeSpinner()
                confirmUserInterface?.displayTryAgain(error)
            }
        }
    }
    
    func continueWithTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO, displayContactItem: AddressBookDisplayItem?) {
        transferUserInterface?.hideErrorValidation()
        txWireframe?.presentConfirmInterface(transaction: transaction, tokenInfo: tokenInfo, displayContactItem: displayContactItem)
    }
    
    func didReceiveError(_ error: String?) {
        confirmUserInterface?.removeSpinner()
        confirmUserInterface?.displayError(error!)
    }
    
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO) {
        transferUserInterface?.updateUserInterfaceWithTokenInfo(tokenInfo)
    }
    
    func didValidateTransferTransaction(_ error: String?, isAddress: Bool) {
        transferUserInterface?.showErrorValidation(error, isAddress: isAddress)
    }
    
    func requestPinToSignTransaction() {
        transactionModuleDelegate?.requestPINInterfaceForTransaction()
    }
    
    func didSendTransactionSuccess(_ transaction: IntermediaryTransactionDTO, tokenInfo: TokenInfoDTO) {
        transactionModuleDelegate?.didSendTxSuccess(transaction, tokenInfo: tokenInfo)
    }
}

extension TransactionPresenter : PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        print("TransactionPresenter - Did receive PIN: \(pin)")
        transactionModuleDelegate?.removePINDelegate()
        txInteractor?.performTransfer(pin: pin)
    }
    
    func cancel() {
    }
}
