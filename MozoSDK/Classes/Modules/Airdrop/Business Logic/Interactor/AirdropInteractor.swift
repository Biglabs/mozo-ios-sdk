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
        if startDate <= Date().addingTimeInterval(60 * 10) {
            return "Time of Start date must larger than current time %d minutes at least.".localizedFormat(10)
        }
        if startDate >= endDate {
            return "Invalid Airdrop start date - end date.".localized
        }
        return nil
    }
    
    func processAirdropEvent(_ event: AirdropEventDTO, tokenInfo: TokenInfoDTO) {
        if let balance = tokenInfo.balance, let decimals = tokenInfo.decimals {
            if event.totalNumMozoOffchain?.doubleValue ?? 0 > balance.convertOutputValue(decimal: decimals) {
                output?.failedToSignAirdropEventWithErrorString("Balance is not enough.".localized)
                return
            }
            let perCustomer = (event.mozoAirdropPerCustomerVisit?.doubleValue ?? 0).convertTokenValue(decimal: decimals)
            let total = (event.totalNumMozoOffchain?.doubleValue ?? 0).convertTokenValue(decimal: decimals)
            event.mozoAirdropPerCustomerVisit = perCustomer
            event.totalNumMozoOffchain = total
            event.symbol = tokenInfo.symbol
            event.decimals = tokenInfo.decimals
            sendCreateAirdropEvent(event)
        } else {
            output?.didFailedToLoadTokenInfo()
        }
    }
    
    func sendCreateAirdropEvent(_ event: AirdropEventDTO) {
        if let errorMsg = validateAirdropEvent(event) {
            output?.failedToSignAirdropEventWithErrorString(errorMsg)
            return
        }
        _ = apiManager?.createAirdropEvent(event: event).done({ (interTxArray) in
            self.transactionDataArray = interTxArray
            if let pin = self.pinToRetry {
                self.sendSignedAirdropEventTx(pin: pin)
            } else {
                self.output?.requestPinInterface()
            }
        }).catch({ (error) in
            let cErr = error as? ConnectionError ?? .systemError
            self.output?.failedToCreateAirdropEvent(error: cErr)
        })
    }
}
extension AirdropInteractor: AirdropInteractorInput {
    func validateAndCalculateEvent(_ event: AirdropEventDTO) {
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
    
    func sendSignedAirdropEventTx(pin: String) {
        signManager?.signMultiTransaction(transactionDataArray!, pin: pin)
            .done { (signedInterTxArray) in
                self.apiManager?.sendSignedAirdropEventTx(signedInterTxArray).done({ (smartContractAddress) in
                    print("Send successfully with smart contract address: \(smartContractAddress ?? "NULL")")
                    // Clear data
                    self.transactionDataArray = nil
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
                self.output?.failedToSignAirdropEvent(error: ConnectionError.systemError)
            })
    }
    
    func clearRetryPin() {
        self.pinToRetry = nil
    }
}
