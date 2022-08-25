//
//  TopUpInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
protocol TopUpInteractorInput {
    func loadTopUpAddress()
    
    func sendSignedTopUpTx(pin: String)
    
    func validateTransferTransaction(amount: String, topUpAddress: String?)
    func topUpTransaction(_ transaction: TransactionDTO, topUpAddress: String?)
    
    func requestToRetryTransfer()
}
protocol TopUpInteractorOutput {
    func didFailedToLoadTokenInfo(error: ConnectionError)
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO)
    
    func didFailedToLoadTopUpAddress(error: ConnectionError)
    func didLoadTopUpAddress(_ address: String)
    
    func failedToPrepareTopUp(error: ConnectionError)
    func failedToSignTopUp(error: ConnectionError)
    
    func didSendSignedTopUpFailure(error: ConnectionError)
    
    func requestPINInterface()
        
    func requestAutoPINInterface()
    
    func validateError(_ error: String)
    func validateSuccessWithTransaction(_ transaction: TransactionDTO)
    
    func requestTxCompletion(tx: IntermediaryTransactionDTO, moduleRequest: Module)
}
