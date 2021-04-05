//
//  TopUpWithdrawPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/19.
//

import Foundation
class TopUpWithdrawPresenter: NSObject {
    var wireframe: TopUpWithdrawWireframe?
    var interactor: TopUpWithdrawInteractorInput?
    weak var delegate: TopUpWithdrawDelegate?
        
    var eventId: Int64?
    var tokenInfo: TokenInfoDTO?
    
    func withdraw() {
        interactor?.withdraw()
    }
}
extension TopUpWithdrawPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        interactor?.sendSignedTx(pin: pin)
    }
    
    func cancel() {
    }
}
extension TopUpWithdrawPresenter: TopUpWithdrawInteractorOutput {
    func requestAutoPINInterface() {
        wireframe?.presentAutoPINInterface(needShowRoot: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS)) {
            self.wireframe?.rootWireframe?.dismissTopViewController()
        }
    }
    
    func failedToWithdraw(error: String?) {
        delegate?.topUpWithdrawFailureWithErrorString(error: error)
    }
    
    func failedToSignTransaction(error: String?) {
        delegate?.topUpWithdrawFailureWithErrorString(error: error)
    }
    
    func didFailedToLoadTokenInfo() {
        NSLog("TopUpWithdrawPresenter - Unable to load token info")
        delegate?.topUpWithdrawFailureWithErrorString(error: "Sorry, something went wrong. Please try again or restart the app".localized)
    }
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType) {
        if statusType == .SUCCESS {
            delegate?.topUpWithdrawSuccess()
            delegate = nil
        } else {
            delegate?.topUpWithdrawFailed()
        }
    }
    
    func didFailedToCreateTransaction(error: ConnectionError) {
        delegate?.topUpWithdrawFailure(error: error)
    }
    
    func didSendSignedTransactionFailure(error: ConnectionError) {
        delegate?.topUpWithdrawFailure(error: error)
    }
    
    func requestPinInterface() {
        wireframe?.presentPinInterface()
    }
}
