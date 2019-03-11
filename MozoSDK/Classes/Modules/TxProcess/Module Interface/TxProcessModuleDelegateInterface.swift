//
//  TxProcessModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
protocol TxProcessModuleDelegate {
    func didReceiveTxStatus(_ status: TransactionStatusType, transaction: IntermediaryTransactionDTO)
}
