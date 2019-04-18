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
}
extension WithdrawPresenter: WithdrawInteractorOutput {
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
            delegate?.withdrawMozoFromAirdropEventFailureWithErrorString(error: "Withdraw MozoX from airdrop event is failed.")
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
