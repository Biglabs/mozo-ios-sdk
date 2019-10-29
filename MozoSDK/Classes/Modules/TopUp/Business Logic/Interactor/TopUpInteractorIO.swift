//
//  TopUpInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
protocol TopUpInteractorInput {
    func clearRetryPin()
    func sendSignedTopUpTx(pin: String)
    func prepareTopUp(_ transaction: TransactionDTO)
}
protocol TopUpInteractorOutput {
    func didFailedToLoadTokenInfo()
    func failedToPrepareTopUp(error: ConnectionError)
    func failedToSignTopUp(error: ConnectionError)
    func failedToSignTopUpWithErrorString(_ error: String?)
    
    func didSendSignedTopUpFailure(error: ConnectionError)
    
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType)
    
    func requestAutoPINInterface()
}
