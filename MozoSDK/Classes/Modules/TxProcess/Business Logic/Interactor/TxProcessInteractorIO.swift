//
//  TxProcessInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
protocol TxProcessInteractorInput {
    func startWaitingTxStatus(_ hash: String)
    func stopService()
}
protocol TxProcessInteractorOutput {
    func didReceiveTxStatus(_ status: TransactionStatusType)
}
