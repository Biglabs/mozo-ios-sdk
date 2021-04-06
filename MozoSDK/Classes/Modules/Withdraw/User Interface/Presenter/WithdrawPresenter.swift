//
//  WithdrawPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/20/19.
//

import Foundation
class WithdrawPresenter: NSObject {
    var wireframe: WithdrawWireframe?
    var interactor: WithdrawInteractorInput?
    weak var delegate: WithdrawAirdropEventDelegate?
    
    var eventId: Int64?
    var tokenInfo: TokenInfoDTO?
    
    func withdrawMozoFromEventId(_ eventId: Int64) {
        interactor?.withdrawMozoFromEventId(eventId)
    }
}
extension WithdrawPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        interactor?.sendSignedTx(pin: pin)
    }
    
    func cancel() {
    }
}
extension WithdrawPresenter: WithdrawInteractorOutput {
    func requestAutoPINInterface() {
        wireframe?.presentAutoPINInterface(needShowRoot: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS)) {
            self.wireframe?.rootWireframe?.dismissTopViewController()
        }
    }
    
    func failedToWithdrawMozoFromEvent(error: String?) {
        delegate?.withdrawMozoFromAirdropEventFailureWithErrorString(error: error)
    }
    
    func failedToSignTransaction(error: String?) {
        delegate?.withdrawMozoFromAirdropEventFailureWithErrorString(error: error)
    }
    
    func didFailedToLoadTokenInfo() {
        NSLog("WithdrawPresenter - Unable to load token info")
        delegate?.withdrawMozoFromAirdropEventFailureWithErrorString(error: "Sorry, something went wrong. Please try again or restart the app".localized)
    }
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType) {
        if statusType == .SUCCESS {
            delegate?.withdrawMozoFromAirdropEventSuccess()
            delegate = nil
        } else {
            delegate?.withdrawMozoFromAirdropEventFailureWithErrorString(error: "error_event_withdraw_failed".localized)
        }
    }
    
    func didFailedToCreateTransaction(error: ConnectionError) {
        delegate?.withdrawMozoFromAirdropEventFailure(error: error)
    }
    
    func didSendSignedTransactionFailure(error: ConnectionError) {
        delegate?.withdrawMozoFromAirdropEventFailure(error: error)
    }
    
    func requestPinInterface() {
        wireframe?.presentPinInterface()
    }
}
