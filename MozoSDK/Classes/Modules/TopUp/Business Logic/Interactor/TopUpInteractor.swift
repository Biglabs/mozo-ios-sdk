//
//  TopUpInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
class TopUpInteractor: NSObject {
    var output: TopUpInteractorOutput?
    var signManager : TransactionSignManager?
    let apiManager : ApiManager
    
    var originalTransaction: TransactionDTO?
    var transactionData : IntermediaryTransactionDTO?
    
    var transactionDataArray : [IntermediaryTransactionDTO]?
    
    var tokenInfo: TokenInfoDTO?
    var pinToRetry: String?
    var topUpAddress: String?
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
    }
    
    @objc func onUserDidCloseAllMozoUI(_ notification: Notification) {
        print("TopUpInteractor - User close Mozo UI, clear pin cache")
        pinToRetry = nil
    }
    
    func requestForPin() {
        if let encryptedPin = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.encryptedPin,
            let pinSecret = AccessTokenManager.getPinSecret() {
            let decryptPin = encryptedPin.decrypt(key: pinSecret)
            pinToRetry = decryptPin
            if SessionStoreManager.getNotShowAutoPINScreen() == true {
                self.sendSignedTopUpTx(pin: decryptPin)
            } else {
                self.output?.requestAutoPINInterface()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS) + .milliseconds(1)) {
                    self.sendSignedTopUpTx(pin: decryptPin)
                }
            }
        } else {
            self.output?.requestPINInterface()
        }
    }
    
    func createTransactionToTransfer(tokenInfo: TokenInfoDTO?, topUpAddress: String?, amount: String?) -> TransactionDTO? {
        let input = InputDTO(addresses: [(tokenInfo?.address)!])!
        let trimToAddress = topUpAddress?.trimmingCharacters(in: .whitespacesAndNewlines)
        var txValue = NSNumber(value: 0)
        if let amount = amount {
            // Fix issue: Get double value from NSNumber, result is incorrect
            txValue = NSDecimalNumber(string: amount).multiplying(by: NSDecimalNumber(decimal: pow(10, tokenInfo?.decimals ?? 0)))
        }
        let outputAddresses = [trimToAddress ?? ""]
        let output = OutputDTO(addresses: outputAddresses, value: txValue)!
        let transaction = TransactionDTO(inputs: [input], outputs: [output])
        
        return transaction
    }
    
    func prepareTopUpTransaction(_ transaction: TransactionDTO) {
        _ = apiManager.prepareTopUpTransaction(transaction.outputs![0].value ?? 0).done{ (interTxArray) in
            // Should keep previous value of transaction
            self.originalTransaction = transaction
            self.transactionDataArray = interTxArray
            if let pin = self.pinToRetry {
                self.sendSignTopUpMultipleTransaction(pin: pin)
            } else {
                self.requestForPin()
            }
        }.catch({ (error) in
            print("Send create topup transaction failed, show popup to retry.")
            // Remember original transaction for retrying.
            self.originalTransaction = transaction
            self.output?.failedToPrepareTopUp(error: error as? ConnectionError ?? .systemError)
        })
    }
    
    func prepareTopUpTransfer(_ transaction: TransactionDTO) {
        _ = apiManager.transferTransaction(transaction).done { (interTx) in
            // Fix issue: Should keep previous value of transaction
            self.originalTransaction = transaction
            self.transactionData = interTx
            if let pin = self.pinToRetry {
                self.sendSignedTopUpTx(pin: pin)
            } else {
                self.requestForPin()
            }
        }.catch({ (error) in
            print("Send create transaction failed, show popup to retry.")
            // Remember original transaction for retrying.
            self.originalTransaction = transaction
            self.output?.failedToPrepareTopUp(error: error as? ConnectionError ?? .systemError)
        })
    }
    
    func sendSignTransfer(pin: String) {
        signManager?.signTransaction(transactionData!, pin: pin)
        .done { (signedInterTx) in
            self.apiManager.sendSignedTransaction(signedInterTx).done({ (receivedTx) in
                print("Send successfully with hash: \(receivedTx.tx?.hash ?? "NULL")")
                // Clear retry PIN
                self.pinToRetry = nil
                // Fix issue: Should keep previous value of transaction
                if let output = self.originalTransaction?.outputs![0] {
                    receivedTx.tx?.outputs![0] = output
                }
                // Clear original transaction
                self.originalTransaction = nil
                print("Original output value: \(receivedTx.tx?.outputs![0].value ?? 0)")
                // TODO: Avoid depending on received transaction data
                self.output?.requestTxCompletion(tokenInfo: self.tokenInfo!, tx: receivedTx, moduleRequest: .TopUpTransfer)
            }).catch({ (err) in
                print("Send signed transaction failed, show popup to retry.")
                self.pinToRetry = pin
                self.output?.didSendSignedTopUpFailure(error: err as? ConnectionError ?? .systemError)
            })
        }.catch({ (err) in
            self.output?.failedToSignTopUp(error: ConnectionError.systemError)
        })
    }
    
    func sendSignTopUpMultipleTransaction(pin: String) {
        signManager?.signMultiTransaction(transactionDataArray!, pin: pin)
        .done { (signedInterTxArray) in
            self.apiManager.sendTopUpSignedTransaction(signedInterTxArray).done({ (smartContractAddress) in
                print("Send successfully with smart contract address: \(smartContractAddress ?? "NULL")")
                // Clear retry PIN
                self.pinToRetry = nil
                // Clear original transaction
                self.transactionDataArray = nil
                if let tokenInfo = self.tokenInfo, let originalTransaction = self.originalTransaction, let interTx = IntermediaryTransactionDTO(tx: originalTransaction) {
                    interTx.tx?.hash = smartContractAddress
                    self.output?.requestTxCompletion(tokenInfo: tokenInfo, tx: interTx, moduleRequest: .TopUp)
                }
                self.originalTransaction = nil
            }).catch({ (err) in
                print("Send signed transaction failed, show popup to retry.")
                self.pinToRetry = pin
                self.output?.didSendSignedTopUpFailure(error: err as? ConnectionError ?? .systemError)
            })
        }.catch({ (err) in
            self.output?.failedToSignTopUp(error: ConnectionError.systemError)
        })
    }
}
extension TopUpInteractor: TopUpInteractorInput {
    func validateTransferTransaction(tokenInfo: TokenInfoDTO, amount: String, topUpAddress: String?) {
        var hasError = false
        
        var isAmountEmpty = false
        let value = amount.toTextNumberWithoutGrouping()
        if value.isEmpty {
            let error = "Error".localized + ": " + "Please input amount.".localized
            isAmountEmpty = true
            hasError = true
            output?.validateError(error)
        }
        
        if !isAmountEmpty {
            let spendable = tokenInfo.balance?.convertOutputValue(decimal: tokenInfo.decimals ?? 0)
            if spendable! <= 0.0 {
                let error = "Error: Your spendable is not enough for this."
                output?.validateError(error)
                return
            }
            
            if Double(value)! > spendable! {
                let error = "Error: Your spendable is not enough for this."
                output?.validateError(error)
                return
            }
            
            if (value.isValidDecimalMinValue(decimal: tokenInfo.decimals ?? 0) == false){
                let error = "Error: Amount is too low, please input valid amount."
                output?.validateError(error)
                return
            }
        }

        if !hasError {
            let tx = createTransactionToTransfer(tokenInfo: tokenInfo, topUpAddress: topUpAddress, amount: value)
            self.tokenInfo = tokenInfo
            output?.validateSuccessWithTransaction(tx!, tokenInfo: tokenInfo)
        }
    }
    
    func topUpTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO, topUpAddress: String?) {
        if self.tokenInfo == nil {
            self.tokenInfo = tokenInfo
        }
        self.topUpAddress = topUpAddress
        
        if topUpAddress == nil || (topUpAddress ?? "").isEmpty {
            prepareTopUpTransaction(transaction)
        } else {
            prepareTopUpTransfer(transaction)
        }
    }
    
    func requestToRetryTransfer() {
        if let transaction = originalTransaction, let tokenInfo = self.tokenInfo {
            topUpTransaction(transaction, tokenInfo: tokenInfo, topUpAddress: self.topUpAddress)
        }
    }
    
    func loadTokenInfo() {
        if let userObj = SessionStoreManager.loadCurrentUser() {
            if let address = userObj.profile?.walletInfo?.offchainAddress {
                print("TopUpInteractor - Address used to load balance: \(address)")
                _ = apiManager.getTokenInfoFromAddress(address)
                    .done { (tokenInfo) in
                        self.output?.didLoadTokenInfo(tokenInfo)
                    }.catch({ (err) in
                        self.output?.didFailedToLoadTokenInfo(error: err as? ConnectionError ?? .systemError)
                    })
            }
        }
    }
    
    func loadTopUpAddress() {
        _ = apiManager.getTopUpAddress().done({ (address) in
            self.output?.didLoadTopUpAddress(address)
        }).catch({ (error) in
            self.output?.didFailedToLoadTopUpAddress(error: error as? ConnectionError ?? .systemError)
        })
    }
    
    func sendSignedTopUpTx(pin: String) {
        if topUpAddress == nil || (topUpAddress ?? "").isEmpty {
            sendSignTopUpMultipleTransaction(pin: pin)
        } else {
            sendSignTransfer(pin: pin)
        }
    }
}
