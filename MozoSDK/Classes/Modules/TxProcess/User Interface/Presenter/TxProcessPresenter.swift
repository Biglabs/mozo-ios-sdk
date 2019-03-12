//
//  TxProcessPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
enum TxProcessStep: Int {
    case Broadcasting = 0
    case Broadcasted = 1
    case Waiting = 2
    
    var delaySeconds : Int {
        return 1
    }
    
    var title: String {
        switch self {
        case .Broadcasting: return "Broadcasting transaction…"
        case .Broadcasted: return "Broadcast completed"
        case .Waiting: return "Waiting for transaction status..."
        }
    }
}
class TxProcessPresenter: NSObject {
    var interactor: TxProcessInteractorInput?
    var delegate: TxProcessModuleDelegate?
    
    var transaction: IntermediaryTransactionDTO?
    
    func startWaitingTxStatus(transaction: IntermediaryTransactionDTO) {
<<<<<<< HEAD
        self.transaction = transaction
=======
>>>>>>> SDK_Version_1.3
        interactor?.startWaitingTxStatus(transaction.tx?.hash ?? "")
    }
}
extension TxProcessPresenter: TxProcessModuleInterface {
    func hideProcess() {
        delegate = nil
        transaction = nil
        interactor?.stopService()
    }
}
extension TxProcessPresenter: TxProcessInteractorOutput {
    func didReceiveTxStatus(_ status: TransactionStatusType) {
        if let transaction = self.transaction {
            delegate?.didReceiveTxStatus(status, transaction: transaction)
        }
    }
}
