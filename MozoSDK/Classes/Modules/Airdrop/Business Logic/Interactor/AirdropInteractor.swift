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
    
    func validateAirdropEvent(_ event: AirdropEventDTO) -> String? {
        let startDate = Date(timeIntervalSince1970: TimeInterval(event.periodFromDate ?? 0))
        let endDate = Date(timeIntervalSince1970: TimeInterval(event.periodToDate ?? 0))
        if startDate > Date().addingTimeInterval(60 * 10) {
            if startDate < endDate {
                return nil
            }
            return "Invalid Airdrop start date - end date."
        }
        return "Time of Start date must larger than current time 10 minutes at least."
    }
    
    func processAirdropEvent(_ event: AirdropEventDTO, tokenInfo: TokenInfoDTO) {
        let perCustomer = (event.mozoAirdropPerCustomerVisit?.doubleValue ?? 0).convertTokenValue(decimal: tokenInfo.decimals ?? 0)
        let total = (event.totalNumMozoOffchain?.doubleValue ?? 0).convertTokenValue(decimal: tokenInfo.decimals ?? 0)
        event.mozoAirdropPerCustomerVisit = perCustomer
        event.totalNumMozoOffchain = total
        output?.didCalculatePerVisitAndTotal(event: event, tokenInfo: tokenInfo)
    }
}
extension AirdropInteractor: AirdropInteractorInput {
    func calculatePerVisitAndTotal(_ event: AirdropEventDTO) {
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
    
    func sendCreateAirdropEvent(_ event: AirdropEventDTO) {
        if let errorMsg = validateAirdropEvent(event) {
            output?.failedToSignAirdropEvent(error: errorMsg)
            return
        }
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
