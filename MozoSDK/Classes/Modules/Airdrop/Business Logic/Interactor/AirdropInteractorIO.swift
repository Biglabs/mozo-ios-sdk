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
    func calculatePerVisitAndTotal(_ event: AirdropEventDTO)
}
protocol AirdropInteractorOutput {
    func didCalculatePerVisitAndTotal(event: AirdropEventDTO, tokenInfo: TokenInfoDTO)
    func didFailedToLoadTokenInfo()
    func failedToCreateAirdropEvent(error: String?)
    func failedToSignAirdropEvent(error: String?)
    
    func didSendSignedAirdropEventFailure(error: ConnectionError)
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType)
}
