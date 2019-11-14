//
//  TopUpInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
protocol TopUpInteractorInput {
    func loadTokenInfo()
    func loadTopUpAddress()
    
    func sendSignedTopUpTx(pin: String)
    
    func validateTransferTransaction(tokenInfo: TokenInfoDTO, amount: String, topUpAddress: String?)
    func topUpTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO, topUpAddress: String?)
    
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
    func validateSuccessWithTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO)
    
    func requestTxCompletion(tokenInfo: TokenInfoDTO, tx: IntermediaryTransactionDTO, moduleRequest: Module)
}
