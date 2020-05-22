//
//  AirdropInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
import SwiftyJSON
public let AIRDROP_START_DATE_LARGER_THAN_CURRENT : Int = 10
public let AIRDROP_FREQUENCY_LARGER_THAN : Int = 1800
class AirdropInteractor: NSObject {
    var output: AirdropInteractorOutput?
    var signManager : TransactionSignManager?
    var apiManager: ApiManager?
    var transactionDataArray : [IntermediaryTransactionDTO]?
    var pinToRetry: String?
    
    var txStatusTimer: Timer?
    var smartContractAddress: String?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
    }
    
    @objc func onUserDidCloseAllMozoUI(_ notification: Notification) {
        print("AirdropInteractor - User close Mozo UI, clear pin cache")
        pinToRetry = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didCloseAllMozoUI, object: nil)
    }
    
    func startWaitingStatusService(smartContractAddress: String) {
        self.smartContractAddress = smartContractAddress
        txStatusTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadSmartContractStatus), userInfo: nil, repeats: true)
    }
    
    func stopService() {
        txStatusTimer?.invalidate()
        txStatusTimer = nil
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
        if event.airdropFreq ?? 0 < AIRDROP_FREQUENCY_LARGER_THAN {
            return "Frequency must be greater than %d minutes".localizedFormat(AIRDROP_FREQUENCY_LARGER_THAN / 60)
        }
        if event.periodFromDate != nil {
            let startDate = Date(timeIntervalSince1970: TimeInterval(event.periodFromDate!))
            let endDate = Date(timeIntervalSince1970: TimeInterval(event.periodToDate ?? 0))
            if startDate >= endDate {
                return "error_date_start_must_earlier_end".localized
            }
        }
        
        return nil
    }
    
    func processAirdropEvent(_ event: AirdropEventDTO, tokenInfo: TokenInfoDTO) {
        if let balance = tokenInfo.balance, let decimals = tokenInfo.decimals {
            if event.totalNumMozoOffchain?.doubleValue ?? 0 > balance.convertOutputValue(decimal: decimals) {
                output?.failedToSignAirdropEventWithErrorString("error_amount_not_enough_to_airdrop".localized)
                return
            }
            let perCustomer = (event.mozoAirdropPerCustomerVisit?.doubleValue ?? 0).convertTokenValue(decimal: decimals)
            let total = (event.totalNumMozoOffchain?.doubleValue ?? 0).convertTokenValue(decimal: decimals)
            let dict = event.toJSON()
            let jobj = JSON(dict)
            if let convertEvent = AirdropEventDTO(json: jobj) {
                convertEvent.mozoAirdropPerCustomerVisit = perCustomer
                convertEvent.totalNumMozoOffchain = total
                convertEvent.symbol = tokenInfo.symbol
                convertEvent.decimals = tokenInfo.decimals
                sendCreateAirdropEvent(convertEvent)
            } else {
                output?.didFailedToLoadTokenInfo()
            }
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
                self.requestForPin()
            }
        }).catch({ (error) in
            let cErr = error as? ConnectionError ?? .systemError
            self.output?.failedToCreateAirdropEvent(error: cErr)
        })
    }
    
    func requestForPin() {
        if let encryptedPin = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.encryptedPin,
            let pinSecret = AccessTokenManager.getPinSecret() {
            let decryptPin = encryptedPin.decrypt(key: pinSecret)
            pinToRetry = decryptPin
            if SessionStoreManager.getNotShowAutoPINScreen() == true {
                self.sendSignedAirdropEventTx(pin: decryptPin)
            } else {
                self.output?.requestAutoPINInterface()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS) + .milliseconds(1)) {
                    self.sendSignedAirdropEventTx(pin: decryptPin)
                }
            }
        } else {
            self.output?.requestPinInterface()
        }
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
