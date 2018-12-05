//
//  AirdropInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
class AirdropInteractor: NSObject {
    var output: AirdropInteractorOutput?
    var signManager : TransactionSignManager?
    var apiManager: ApiManager?
    var transactionDataArray : [IntermediaryTransactionDTO]?
    var pinToRetry: String?
    
    var txStatusTimer: Timer?
    var smartContractAddress: String?
    
    func startWaitingStatusService(smartContractAddress: String) {
        self.smartContractAddress = smartContractAddress
        txStatusTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadSmartContractStatus), userInfo: nil, repeats: true)
    }
    
    func stopService() {
        txStatusTimer?.invalidate()
    }
    
    @objc func loadSmartContractStatus() {
        if let smartContractAddress = self.smartContractAddress {
            _ = apiManager?.getSmartContractStatus(address: smartContractAddress).done({ (type) in
                self.handleWaitingStatusCompleted(statusType: type)
            })
        }
    }
    
    func handleWaitingStatusCompleted(statusType: TransactionStatusType) {
        if statusType != TransactionStatusType.PENDING {
            self.output?.didReceiveTxStatus(statusType)
            self.stopService()
        }
    }
}
extension AirdropInteractor: AirdropInteractorInput {
    func sendCreateAirdropEvent(_ event: AirdropEventDTO) {
        _ = apiManager?.createAirdropEvent(event: event).done({ (interTxArray) in
            for interTx in interTxArray {
                if (interTx.errors != nil) && (interTx.errors?.count)! > 0 {
                    self.output?.failedToCreateAirdropEvent(error: interTx.errors?.first)
                    return
                }
            }
            self.transactionDataArray = interTxArray
            if let pin = self.pinToRetry {
                self.sendSignedAirdropEventTx(pin: pin)
            } else {
                self.output?.requestPinInterface()
            }
        }).catch({ (error) in
            let cErr = error as! ConnectionError
            self.output?.failedToCreateAirdropEvent(error: cErr.errorDescription)
        })        
    }
    
    func sendSignedAirdropEventTx(pin: String) {
        signManager?.signMultiTransaction(transactionDataArray!, pin: pin)
            .done { (signedInterTxArray) in
                self.apiManager?.sendSignedAirdropEventTx(signedInterTxArray).done({ (smartContractAddress) in
                    print("Send successfully with smart contract address: \(smartContractAddress ?? "NULL")")
                    // Clear retry PIN
                    self.clearRetryPin()
                    if let scAddress = smartContractAddress {
                        self.startWaitingStatusService(smartContractAddress: scAddress)
                    }
                }).catch({ (err) in
                    print("Send signed transaction failed, show popup to retry.")
                    self.pinToRetry = pin
                    self.output?.didSendSignedAirdropEventFailure(error: err as! ConnectionError)
                })
            }.catch({ (err) in
                self.output?.failedToSignAirdropEvent(error: err.localizedDescription)
            })
    }
    
    func clearRetryPin() {
        self.pinToRetry = nil
    }
}
