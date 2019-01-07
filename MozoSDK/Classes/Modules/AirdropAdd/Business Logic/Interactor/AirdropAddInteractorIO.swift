//
//  AirdropAddInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
protocol AirdropAddInteractorInput {
    func sendSignedTx(pin: String)
    func addMoreMozoToEvent(_ event: AirdropEventDTO)
}
protocol AirdropAddInteractorOutput {
    func didFailedToLoadTokenInfo()
    func failedToAddMozoToAirdropEvent(error: String?)
    func failedToSignTransaction(error: String?)
    
    func didSendSignedTransactionFailure(error: ConnectionError)
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType)
}
