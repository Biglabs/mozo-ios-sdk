//
//  TxCompletionInteractor.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/7/18.
//

import Foundation

class TxCompletionInteractor: NSObject {
    var output: TxCompletionInteractorOutput?
    let apiManager: ApiManager
    var txStatusTimer: Timer?
    var txHash: String?
    
    var moduleRequest = Module.Transaction
    
    init(apiManager : ApiManager) {
        self.apiManager = apiManager
    }
    
    @objc func loadTxStatus() {
        if moduleRequest == .TopUp {
            if let smartContractAddress = self.txHash {
                _ = apiManager.getTopUpTxStatus(smartContractAddress: smartContractAddress).done({ (type) in
                    self.handleTxCompleted(statusType: type)
                })
            }
            return
        }
        if let txHash = self.txHash {
            _ = apiManager.getTxStatus(hash: txHash).done({ (type) in
                self.handleTxCompleted(statusType: type)
            }).catch({ (error) in
                self.stopService()
                self.output?.didReceiveError(error: error as? ConnectionError ?? .systemError)
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

extension TxCompletionInteractor: TxCompletionInteractorInput {
    func startWaitingStatusService(hash: String, moduleRequest: Module) {
        self.moduleRequest = moduleRequest
        self.txHash = hash
        txStatusTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadTxStatus), userInfo: nil, repeats: true)
    }
    
    func stopService() {
        txStatusTimer?.invalidate()
    }
}
