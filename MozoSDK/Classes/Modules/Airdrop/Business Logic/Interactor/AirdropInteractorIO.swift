//
//  AirdropInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
protocol AirdropInteractorInput {
    func clearRetryPin()
    func sendSignedAirdropEventTx(pin: String)
    func validateAndCalculateEvent(_ event: AirdropEventDTO)
}
protocol AirdropInteractorOutput {
    func didFailedToLoadTokenInfo()
    func failedToCreateAirdropEvent(error: ConnectionError)
    func failedToSignAirdropEvent(error: ConnectionError)
    func failedToSignAirdropEventWithErrorString(_ error: String?)
    
    func didSendSignedAirdropEventFailure(error: ConnectionError)
    
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType)
    
    func requestAutoPINInterface()
}
