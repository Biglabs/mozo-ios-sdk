//
//  TopUpPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
class TopUpPresenter: NSObject {
    var wireframe: TopUpWireframe?
    var interactor: TopUpInteractorInput?
    var topUpDelegate: TopUpDelegate?
    
    func prepareTransactionTopUp(amount: NSNumber) {
        
    }
}
extension TopUpPresenter: TopUpModuleDelegate {
    func didConfirmTopUpTransaction(_ tx: TransactionDTO) {
        
    }
}
extension TopUpPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        interactor?.sendSignedTopUpTx(pin: pin)
    }
}
extension TopUpPresenter: TopUpInteractorOutput {
    func didFailedToLoadTokenInfo() {
        NSLog("TopUpPresenter - Unable load token info")
        // Show try again here
    }
    
    func failedToPrepareTopUp(error: ConnectionError) {
        // Show try again here
    }
    
    func failedToSignTopUp(error: ConnectionError) {
        // Show try again here
    }
    
    func failedToSignTopUpWithErrorString(_ error: String?) {
        // Show try again here
    }
    
    func didSendSignedTopUpFailure(error: ConnectionError) {
        // Show try again here
    }
    
    func requestPinInterface() {
        
    }
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType) {
        if statusType == .SUCCESS {
            topUpDelegate?.topUpSuccess()
            topUpDelegate = nil
        } else {
            
        }
    }
    
    func requestAutoPINInterface() {
        wireframe?.presentAutoPINInterface()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS)) {
            self.wireframe?.rootWireframe?.dismissTopViewController()
        }
    }
}
