//
//  WithdrawInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/20/19.
//

import Foundation
class WithdrawInteractor: NSObject {
    var output: WithdrawInteractorOutput?
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
        print("WithdrawInteractor - User close Mozo UI, clear pin cache")
        pinToRetry = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didCloseAllMozoUI, object: nil)
    }
    
    func sendPrepareWithdrawTransaction(_ eventId: Int64) {
        _ = apiManager?.withdrawAirdropEvent(eventId: eventId).done { (interTx) in
            self.transaction = interTx
            self.output?.requestPinInterface()
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
}
extension WithdrawInteractor: WithdrawInteractorInput {
    func withdrawMozoFromEventId(_ eventId: Int64) {
        _ = apiManager?.withdrawAirdropEvent(eventId: eventId).done { (interTx) in
            self.transaction = interTx
            self.requestForPin()
        }.catch({ (error) in
            let cErr = error as? ConnectionError ?? .systemError
            self.output?.didFailedToCreateTransaction(error: cErr)
        })
    }
    
    func sendSignedTx(pin: String) {
        signManager?.signTransaction(transaction!, pin: pin)
            .done { (signedInterTx) in
                self.apiManager?.sendSignedWithdrawAirdropEventTx(signedInterTx).done({ (receivedTx) in
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
