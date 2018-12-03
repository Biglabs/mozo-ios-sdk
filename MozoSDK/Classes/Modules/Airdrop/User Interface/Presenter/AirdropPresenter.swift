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
    
    func requestMultiSign(signature: Signature) {
        itemToSign = signature
        wireframe?.presentPinInterfaceForMultiSign()
    }
    
    func createAirdropEvent(_ event: AirdropEventDTO) {
        self.airdropEvent = event
        interactor?.sendCreateAirdropEvent(airdropEvent!)
    }
}
extension AirdropPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        if let event = airdropEvent {
            interactor?.sendCreateAirdropEvent(event)
        }
    }
}
extension AirdropPresenter: AirdropInteractorOutput {
    func didSendSignedAirdropEventFailure(error: ConnectionError) {
        airdropEventDelegate?.createAirdropEventFailure(error: error.errorDescription, isDisplayingTryAgain: true)
        DisplayUtils.displayTryAgainPopup(delegate: self)
    }
    
    func requestPinInterface() {
        wireframe?.presentPinInterfaceForMultiSign()
    }
    
    func failedToSignAirdropEvent(error: String?) {
        airdropEventDelegate?.createAirdropEventFailure(error: error, isDisplayingTryAgain: false)
    }
    
    func failedToCreateAirdropEvent(error: String?) {
        airdropEventDelegate?.createAirdropEventFailure(error: error, isDisplayingTryAgain: false)
    }
    
    func didCreateAndSignAirdropEventSuccess() {
        airdropEventDelegate?.createAirdropEventSuccess()
    }
}
extension AirdropPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        interactor?.sendCreateAirdropEvent(airdropEvent!)
    }
    
    func didClosePopupWithoutRetry() {
        interactor?.clearRetryPin()
    }
}
