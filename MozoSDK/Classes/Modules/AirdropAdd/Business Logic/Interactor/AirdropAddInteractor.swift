//
//  AirdropAddInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
class AirdropAddInteractor: NSObject {
    var output: AirdropAddInteractorOutput?
    var signManager : TransactionSignManager?
    var apiManager: ApiManager?
    var transaction : IntermediaryTransactionDTO?
    var pinToRetry: String?
    
    var smartContractAddress: String?
    
    func processAirdropEvent(_ event: AirdropEventDTO, tokenInfo: TokenInfoDTO) {
        let totalInDouble = event.totalNumMozoOffchain?.doubleValue ?? 0
        
        if totalInDouble > (tokenInfo.balance ?? 0).convertOutputValue(decimal: tokenInfo.decimals ?? 0) {
            output?.failedToAddMozoToAirdropEvent(error: "Balance is not enough.")
            return
        }
        let total = totalInDouble.convertTokenValue(decimal: tokenInfo.decimals ?? 0)
        if let tx = transactionToTransfer(tokenInfo: tokenInfo, toAdress: event.smartAddress ?? "", amount: total) {
            sendTransaction(tx, tokenInfo: tokenInfo)
        } else {
            output?.failedToAddMozoToAirdropEvent(error: "Unable to create transaction.")
        }
    }
    
    func transactionToTransfer(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: NSNumber) -> TransactionDTO? {
        let input = InputDTO(addresses: [(tokenInfo?.address)!])!
        let trimToAddress = toAdress?.trimmingCharacters(in: .whitespacesAndNewlines)
        let output = OutputDTO(addresses: [trimToAddress!], value: amount)!
        let transaction = TransactionDTO(inputs: [input], outputs: [output])
        
        return transaction
    }
    
    func sendTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO) {
        _ = apiManager?.transferTransaction(transaction).done { (interTx) in
            if (interTx.errors != nil) && (interTx.errors?.count)! > 0 {
                self.output?.failedToAddMozoToAirdropEvent(error: interTx.errors?.first)
            } else {
                self.transaction = interTx
                self.output?.requestPinInterface()
            }
        }.catch({ (error) in
            print("Send create transaction failed, show popup to retry.")
            
        })
    }
    
    var txStatusTimer: Timer?
    var txHash: String?
    
    func startWaitingStatusService(txHash: String) {
        self.txHash = txHash
        txStatusTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadTransactionStatus), userInfo: nil, repeats: true)
    }
    
    func stopService() {
        txStatusTimer?.invalidate()
    }
    
    @objc func loadTransactionStatus() {
        if let txHash = self.txHash {
            _ = apiManager?.getTxStatus(hash: txHash).done({ (statusType) in
                if statusType != TransactionStatusType.PENDING {
                    self.output?.didReceiveTxStatus(statusType)
                    self.stopService()
                }
            })
        }
    }
}
extension AirdropAddInteractor: AirdropAddInteractorInput {
    func addMoreMozoToEvent(_ event: AirdropEventDTO) {
        if let userObj = SessionStoreManager.loadCurrentUser() {
            if let address = userObj.profile?.walletInfo?.offchainAddress {
                print("Address used to load balance: \(address)")
                _ = apiManager?.getTokenInfoFromAddress(address)
                    .done { (tokenInfo) in
                        self.processAirdropEvent(event, tokenInfo: tokenInfo)
                    }.catch({ (err) in
                        self.output?.didFailedToLoadTokenInfo()
                    })
            }
        }
    }
    
    func sendSignedTx(pin: String) {
        signManager?.signTransaction(transaction!, pin: pin)
            .done { (signedInterTx) in
                self.apiManager?.sendAddMoreSignedAirdropEventTx(signedInterTx).done({ (receivedTx) in
                    print("Send successfully with hash: \(receivedTx.tx?.hash ?? "NULL")")
                    self.startWaitingStatusService(txHash: receivedTx.tx?.hash ?? "")
                }).catch({ (err) in
                    print("Send signed transaction failed, show popup to retry.")
                    self.output?.didSendSignedTransactionFailure(error: err as! ConnectionError)
                })
            }.catch({ (err) in
                self.output?.failedToSignTransaction(error: err.localizedDescription)
            })
    }
}
