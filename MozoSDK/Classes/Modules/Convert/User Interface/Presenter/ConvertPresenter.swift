//
//  ConvertPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
class ConvertPresenter: NSObject {
    var wireframe: ConvertWireframe?
    var interactor: ConvertInteractorInput?
    var convertViewInterface: ConvertViewInterface?
    var confirmConvertViewInterface: ConfirmConvertViewInterface?
    
    var delegate: ConvertModuleDelegate?
        
    var isDisplayingConfirm = false
    
    func handleError(_ error: ConnectionError) {
        if isDisplayingConfirm {
            confirmConvertViewInterface?.removeSpinner()
        }
        if error == .requestTimedOut || error == .noInternetConnection {
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, error: error, delegate: self)
        } else {
            if isDisplayingConfirm {
                DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, error: error, delegate: self)
                return
            }
            DisplayUtils.displayMozoErrorWithContact(error.localizedDescription)
        }
    }
}
extension ConvertPresenter: ConvertModuleInterface {
    func loadEthAndOnchainInfo() {
        interactor?.loadEthAndOnchainInfo()
    }
    
    func loadGasPrice() {
        interactor?.loadGasPrice()
    }
    
    func openReadMore() {
        
    }
    
    func validateTxConvert(onchainInfo: OnchainInfoDTO, amount: String, gasPrice: NSNumber, gasLimit: NSNumber) {
        interactor?.validateTxConvert(onchainInfo: onchainInfo, amount: amount, gasPrice: gasPrice, gasLimit: gasLimit)
    }
    
    func sendConfirmConvertTx(_ tx: ConvertTransactionDTO, onchainInfo: OnchainInfoDTO) {
        confirmConvertViewInterface?.displaySpinner()
        interactor?.sendConfirmConvertTx(tx, onchainInfo: onchainInfo)
    }
}
extension ConvertPresenter: ConvertInteractorOutput {
    func errorOccurred() {
        handleError(.systemError)
    }
    
    func didReceiveEthAndOnchainInfo(_ onchainInfo: OnchainInfoDTO) {
        convertViewInterface?.didReceiveOnchainInfo(onchainInfo)
    }
    
    func didReceiveGasPrice(_ gasPrice: GasPriceDTO) {
        convertViewInterface?.didReceiceGasPrice(gasPrice)
    }
    
    func didValidateConvertTx(_ error: String) {
        convertViewInterface?.displayError(error)
    }
    
    func didReceiveErrorWhileLoadingOnchainInfo(_ error: ConnectionError) {
        handleError(error)
    }
    
    func didReceiveErrorWhileLoadingGasPrice(_ error: ConnectionError) {
        handleError(error)
    }
    
    func continueWithTransaction(_ transaction: ConvertTransactionDTO, onchainInfo: OnchainInfoDTO, gasPrice: NSNumber, gasLimit: NSNumber) {
        isDisplayingConfirm = true
        wireframe?.presentConfirmInterface(transaction, onchainInfo: onchainInfo, gasLimit: gasLimit, gasPrice: gasPrice)
    }
    
    func requestPinToSignTransaction() {
        wireframe?.presentPinInterface()
    }
    
    func performTransferWithError(_ error: ConnectionError) {
        handleError(error)
    }
    
    func didSendConvertTransactionSuccess(_ transaction: IntermediaryTransactionDTO, onchainInfo: OnchainInfoDTO) {
        wireframe?.presentTrasactionProcess(transaction)
    }
}
extension ConvertPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        if isDisplayingConfirm {
            confirmConvertViewInterface?.displaySpinner()
            interactor?.requestToRetryTransfer()
        } else {
            loadEthAndOnchainInfo()
            loadGasPrice()
        }
    }
    
    func didClosePopupWithoutRetry() {
        
    }
}
extension ConvertPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        interactor?.performTransfer(pin: pin)
    }    
}
extension ConvertPresenter: TxProcessModuleDelegate {
    func didReceiveTxStatus(_ status: TransactionStatusType, transaction: IntermediaryTransactionDTO) {
        wireframe?.txProcessWireframe?.presenter?.delegate = nil
        wireframe?.presentConvertCompletion(transaction, status: status)
    }
}
