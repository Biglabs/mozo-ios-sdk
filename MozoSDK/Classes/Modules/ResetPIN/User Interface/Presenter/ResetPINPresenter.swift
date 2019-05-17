//
//  ResetPINPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/9/19.
//

import Foundation
class ResetPINPresenter: NSObject {
    var wireframe: ResetPINWireframe?
    var interactor: ResetPINInteractorInput?
    var viewInterface: ResetPINViewInterface?
    
    var retryOnMnemonics: String?
    var retryOnPin: String?
}
extension ResetPINPresenter: ResetPINModuleInterface {
    func checkMnemonics(_ mnemonics: String) {
        interactor?.validateMnemonics(mnemonics)
    }
    
    func resetPINWithMnemonics(_ mnemonics: String) {
        viewInterface?.displayWaiting(isChecking: true)
        interactor?.validateMnemonicsForRestore(mnemonics)
    }
    
    func completeResetPIN() {
        wireframe?.dismissResetPINInterface()
    }
}
extension ResetPINPresenter: ResetPINInteractorOutput {
    func allowGoNext() {
        viewInterface?.allowGoNext()
    }
    
    func disallowGoNext() {
        viewInterface?.disallowGoNext()
    }
    
    func validateFailedForRestore() {
        viewInterface?.closeWaiting(clearData: false, displayTryAgain: false)
        viewInterface?.disallowGoNext()
    }
    
    func mnemonicsNotBelongToUserWallet() {
        viewInterface?.closeWaiting(clearData: false, displayTryAgain: false)
        viewInterface?.mnemonicsNotBelongToUserWallet()
    }
    
    func requestEnterNewPIN(mnemonics: String) {
        viewInterface?.displayWaiting(isChecking: false)
        wireframe?.presentPINInterface(mnemonics: mnemonics)
    }
    
    func resetPINSuccess() {
        wireframe?.presentResetPINSuccessInterface()
    }
    
    func manageResetFailedWithError(_ error: ConnectionError) {
        var displayTryAgain = true
        if error == .apiError_MAINTAINING {
            displayTryAgain = false
        }
        viewInterface?.closeWaiting(clearData: true, displayTryAgain: displayTryAgain)
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, isEmbedded: true, error: error, delegate: self)
    }
}
extension ResetPINPresenter: ResetPINModuleDelegate {
    func manageWalletWithMnemonics(mnemonics: String, pin: String) {
        retryOnMnemonics = mnemonics
        retryOnPin = pin
        interactor?.manageResetPINForWallet(mnemonics, pin: pin)
    }
}
extension ResetPINPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        if let mnemonics = self.retryOnMnemonics, let pin = self.retryOnPin {
            interactor?.manageResetPINForWallet(mnemonics, pin: pin)
        } else {
            print("ResetPINPresenter - Unable to retry")
            viewInterface?.closeWaiting(clearData: false, displayTryAgain: false)
        }
    }
    
    func didClosePopupWithoutRetry() {
        
    }
}
