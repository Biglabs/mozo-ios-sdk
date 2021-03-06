//
//  TxCompletionInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/8/18.
//

import Foundation

protocol TxCompletionInteractorInput {
    func startWaitingStatusService(hash: String, moduleRequest: Module)
    func stopService()
}

protocol TxCompletionInteractorOutput {
    func didReceiveTxStatus(_ status: TransactionStatusType)
    func didReceiveError(error: ConnectionError)
}
