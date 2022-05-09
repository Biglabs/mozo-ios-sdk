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
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
    }
    
    @objc func onUserDidCloseAllMozoUI(_ notification: Notification) {
        print("AirdropAddInteractor - User close Mozo UI, clear pin cache")
        pinToRetry = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didCloseAllMozoUI, object: nil)
    }
    
    func processAirdropEvent(_ event: AirdropEventDTO, tokenInfo: TokenInfoDTO) {
        let totalInDouble = event.totalNumMozoOffchain?.doubleValue ?? 0
        
        if totalInDouble > (tokenInfo.balance ?? 0).convertOutputValue(decimal: tokenInfo.decimals ?? 0) {
            output?.failedToAddMozoToAirdropEvent(error: "error_invalid_total_amount".localized)
            return
        }
        let total = totalInDouble.convertTokenValue(decimal: tokenInfo.decimals ?? 0)
        if let tx = transactionToTransfer(tokenInfo: tokenInfo, toAdress: event.smartAddress ?? "", amount: total) {
            sendTransaction(tx, tokenInfo: tokenInfo)
        } else {
            output?.failedToAddMozoToAirdropEvent(error: "Unable to create transaction.".localized)
        }
    }
    
    func transactionToTransfer(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: NSNumber) -> TransactionDTO? {
        let input = InputDTO(addresses: [(tokenInfo?.address)!])!
        let trimToAddress = toAdress?.trim()
        let output = OutputDTO(addresses: [trimToAddress!], value: amount)!
        let transaction = TransactionDTO(inputs: [input], outputs: [output])
        
        return transaction
    }
    
    func requestForPin() {
        if let encryptedPin = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.encryptedPin,
            let pinSecret = AccessTokenManager.getPinSecret() {
            let decryptPin = encryptedPin.decrypt(key: pinSecret)
            if SessionStoreManager.getNotShowAutoPINScreen() == true {
                self.sendSignedTx(pin: decryptPin)
            } else {
                self.output?.requestAutoPINInterface()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS) + .milliseconds(1)) {
                    self.sendSignedTx(pin: decryptPin)
                }
            }
        } else {
            self.output?.requestPinInterface()
        }
    }
    
    func sendTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO) {
        _ = apiManager?.prepareAddMoreTx(transaction).done { (interTx) in
            self.transaction = interTx
            self.requestForPin()
        }.catch({ (error) in
            let cErr = error as? ConnectionError ?? .systemError
            self.output?.didFailedToCreateTransaction(error: cErr)
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
        txStatusTimer = nil
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
                        SessionStoreManager.tokenInfo = tokenInfo
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
                    let cErr = err as? ConnectionError ?? .systemError
                    self.output?.didSendSignedTransactionFailure(error: cErr)
                })
            }.catch({ (err) in
                self.output?.failedToSignTransaction(error: ConnectionError.systemError.localizedDescription)
            })
    }
}
