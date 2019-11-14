//
//  TopUpWithdrawInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/19.
//

import Foundation

protocol TopUpWithdrawInteractorInput {
    func sendSignedTx(pin: String)
    func withdraw()
}
protocol TopUpWithdrawInteractorOutput {
    func didFailedToLoadTokenInfo()
    func failedToWithdraw(error: String?)
    func failedToSignTransaction(error: String?)
    
    func didFailedToCreateTransaction(error: ConnectionError)
    func didSendSignedTransactionFailure(error: ConnectionError)
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType)
    
    func requestAutoPINInterface()
}
