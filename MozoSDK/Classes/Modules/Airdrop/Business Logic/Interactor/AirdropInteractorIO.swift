//
//  AirdropInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
protocol AirdropInteractorInput {
    func sendCreateAirdropEvent(_ event: AirdropEventDTO)
    func clearRetryPin()
    func sendSignedAirdropEventTx(pin: String)
}
protocol AirdropInteractorOutput {
    func failedToCreateAirdropEvent(error: String?)
    func failedToSignAirdropEvent(error: String?)
    
    func didSendSignedAirdropEventFailure(error: ConnectionError)
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType)
}
