//
//  TxProcessInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
class TxProcessInteractor: NSObject {
    let apiManager: ApiManager
    var output: TxProcessInteractorOutput?
    var txStatusTimer: Timer?
    var txHash: String?
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
        super.init()
    }
    
    @objc func loadTxStatus() {
        if let txHash = self.txHash {
            _ = apiManager.getOnchainTxStatus(hash: txHash).done({ (type) in
                self.handleTxCompleted(statusType: type)
            })
        }
    }
    
    func handleTxCompleted(statusType: TransactionStatusType) {
        if statusType != TransactionStatusType.PENDING {
            self.output?.didReceiveTxStatus(statusType)
            self.stopService()
        }
    }
}
extension TxProcessInteractor: TxProcessInteractorInput {
    func startWaitingTxStatus(_ hash: String) {
        self.txHash = hash
        txStatusTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadTxStatus), userInfo: nil, repeats: true)
    }
    
    func stopService() {
        txStatusTimer?.invalidate()
    }
}
