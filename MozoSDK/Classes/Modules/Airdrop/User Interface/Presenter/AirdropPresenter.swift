//
//  AirdropPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
class AirdropPresenter: NSObject {
    var wireframe: AirdropWireframe?
    var interactor: AirdropInteractorInput?
    weak var multiSignDelegate: MultiSignDelegate?
    weak var airdropEventDelegate: AirdropEventDelegate?
    
    var itemToSign: Signature?
    var airdropEvent: AirdropEventDTO?
    var tokenInfo: TokenInfoDTO?
    
    func requestMultiSign(signature: Signature) {
        itemToSign = signature
        wireframe?.presentPinInterfaceForMultiSign()
    }
    
    func createAirdropEvent(_ event: AirdropEventDTO) {
        self.airdropEvent = event
        interactor?.validateAndCalculateEvent(event)
    }
}
extension AirdropPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        interactor?.sendSignedAirdropEventTx(pin: pin)
    }
}
extension AirdropPresenter: AirdropInteractorOutput {
    func didFailedToLoadTokenInfo() {
        NSLog("AirdropPresenter - Unable load token info")
        airdropEventDelegate?.createAirdropEventFailureWithErrorString(error: "Sorry, something went wrong. Please try again or restart the app".localized, isDisplayingTryAgain: true)
    }
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType) {
        if statusType == .SUCCESS {
            airdropEventDelegate?.createAirdropEventSuccess()
            airdropEventDelegate = nil
        } else {
            airdropEventDelegate?.createAirdropEventFailureWithErrorString(error: "Create Airdrop Event failed.\nPlease try again.".localized, isDisplayingTryAgain: false)
            // Not retry if transaction status is FAILED
//            DisplayUtils.displayTryAgainPopup(delegate: self)
        }
    }

    func didSendSignedAirdropEventFailure(error: ConnectionError) {
        airdropEventDelegate?.createAirdropEventFailure(error: error, isDisplayingTryAgain: true)
        if error.isApiError, let apiError = error.apiError, apiError == ErrorApiResponse.USER_DEACTIVATED {
            NSLog("User account is not authorized access.")
        } else {
            DisplayUtils.displayTryAgainPopup(delegate: self)
        }
    }
    
    func requestPinInterface() {
        wireframe?.presentPinInterfaceForMultiSign()
    }
    
    func failedToSignAirdropEvent(error: ConnectionError) {
        airdropEventDelegate?.createAirdropEventFailure(error: error, isDisplayingTryAgain: false)
    }
    
    func failedToSignAirdropEventWithErrorString(_ error: String?) {
        airdropEventDelegate?.createAirdropEventFailureWithErrorString(error: error, isDisplayingTryAgain: false)
    }
    
    func failedToCreateAirdropEvent(error: ConnectionError) {
        airdropEventDelegate?.createAirdropEventFailure(error: error, isDisplayingTryAgain: false)
    }
}
extension AirdropPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        self.createAirdropEvent(airdropEvent!)
    }
    
    func didClosePopupWithoutRetry() {
        interactor?.clearRetryPin()
    }
}
