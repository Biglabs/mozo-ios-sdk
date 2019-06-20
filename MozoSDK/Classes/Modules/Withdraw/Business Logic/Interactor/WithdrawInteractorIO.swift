//
//  WithdrawInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/20/19.
//

import Foundation

protocol WithdrawInteractorInput {
    func sendSignedTx(pin: String)
    func withdrawMozoFromEventId(_ eventId: Int64)
}
protocol WithdrawInteractorOutput {
    func didFailedToLoadTokenInfo()
    func failedToWithdrawMozoFromEvent(error: String?)
    func failedToSignTransaction(error: String?)
    
    func didFailedToCreateTransaction(error: ConnectionError)
    func didSendSignedTransactionFailure(error: ConnectionError)
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType)
    
    func requestAutoPINInterface()
}
