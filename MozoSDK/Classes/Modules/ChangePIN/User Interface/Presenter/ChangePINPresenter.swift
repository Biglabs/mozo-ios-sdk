//
//  ChangePINPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINPresenter: NSObject {
    var wireframe: ChangePINWireframe?
    var processInterface: ChangePINProcessViewInterface?
    var interactor: ChangePINInteractorInput?
    
    var currentPinToChange: String?
    var newPin: String?
    
    func checkRememberPIN() {
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
            wallet.encryptSeedPhrase != nil {
            if let encryptedPin = wallet.encryptedPin, let pinSecret = AccessTokenManager.getPinSecret() {
                let decryptPin = encryptedPin.decrypt(key: pinSecret)
                self.currentPinToChange = decryptPin
                self.wireframe?.presentPINInterface(enterNewPINToChangePIN: true)
            } else {
                wireframe?.presentPINInterface()
            }
        } else {
            // System error
        }
    }
    
    func processChangePIN() {
        if let currentPin = self.currentPinToChange, let newPin = self.newPin {
            interactor?.changePIN(currentPIN: currentPin, newPIN: newPin)
        } else {
            // System error
        }
    }
}
extension ChangePINPresenter: ChangePINModuleInterface {
    func finishChangePIN() {
        wireframe?.dismissModuleInterface()
    }
}
extension ChangePINPresenter: ChangePINInteractorOutput {
    func changePINFailedWithError(_ error: ConnectionError) {
//        if error == .noInternetConnection || error == .requestTimedOut || error == .apiError_MAINTAINING {
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, isEmbedded: true, error: error, delegate: self)
//        } else {
//            processInterface?.displayError(error.apiError?.description ?? error.localizedDescription)
//        }
    }
    
    func changePINSuccess() {
        wireframe?.presentChangePINSuccessInterface()
        currentPinToChange = nil
        newPin = nil
    }
}
extension ChangePINPresenter: ChangePINModuleDelegate {
    func verifiedCurrentPINSuccess(_ pin: String) {
        self.currentPinToChange = pin
        self.wireframe?.presentPINInterface(enterNewPINToChangePIN: true)
    }
    
    func inputNewPINSuccess(_ pin: String) {
        self.newPin = pin
        processChangePIN()
    }
}
extension ChangePINPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        processChangePIN()
    }
    
    func didClosePopupWithoutRetry() {
        
    }
}
