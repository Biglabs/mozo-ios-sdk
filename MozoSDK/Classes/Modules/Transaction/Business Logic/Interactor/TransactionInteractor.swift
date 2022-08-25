//
//  TransactionInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

class TransactionInteractor : NSObject {
    var output : TransactionInteractorOutput?
    var signManager : TransactionSignManager?
    let apiManager : ApiManager
    
    var originalTransaction: TransactionDTO?
    var transactionData : IntermediaryTransactionDTO?
    var pinToRetry: String?
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
    }
    
    func createTransactionToTransfer(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: String?) -> TransactionDTO? {
        let input = InputDTO(addresses: [(tokenInfo?.address)!])!
        let trimToAddress = toAdress?.trim()
        var txValue = NSNumber(value: 0)
        if let amount = amount {
            // Fix issue: Convert Double value from String incorrectly
            // Fix issue: Get double value from NSNumber, result is incorrect
            txValue = NSDecimalNumber(string: amount).multiplying(by: NSDecimalNumber(decimal: pow(10, tokenInfo?.decimals ?? 0)))
//                .doubleValue.convertTokenValue(decimal: tokenInfo?.decimals ?? 0)
        }
        
        let output = OutputDTO(addresses: [trimToAddress!], value: txValue)!
        let transaction = TransactionDTO(inputs: [input], outputs: [output])
        
        return transaction
    }
    
    @objc func onUserDidCloseAllMozoUI(_ notification: Notification) {
        print("TransactionInteractor - User close Mozo UI, clear pin cache")
        pinToRetry = nil
    }
    
    func requestForPin() {
        if let encryptedPin = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.encryptedPin,
            let pinSecret = AccessTokenManager.getPinSecret() {
            let decryptPin = encryptedPin.decrypt(key: pinSecret)
            pinToRetry = decryptPin
            if SessionStoreManager.getNotShowAutoPINScreen() == true {
                self.performTransfer(pin: decryptPin)
            } else {
                self.output?.requestAutoPINInterface()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS) + .milliseconds(1)) {
                    self.performTransfer(pin: decryptPin)
                }
            }
        } else {
            self.output?.requestPinToSignTransaction()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didCloseAllMozoUI, object: nil)
    }
}

extension TransactionInteractor : TransactionInteractorInput {
    func validateValueFromScanner(_ scanValue: String) {
        if !scanValue.isEthAddress() {
            output?.didValidateTransferTransaction("Error".localized + ": " + "Scanning value is not a valid address.".localized, isAddress: true)
        } else {
            let list = SafetyDataManager.shared.addressBookList
            if let addressBook = AddressBookDTO.addressBookFromAddress(scanValue, array: list) {
                let displayItem = AddressBookDisplayItem(id: addressBook.id ?? 0, name: addressBook.name ?? "", address: addressBook.soloAddress ?? "", physicalAddress: "", isStoreBook: false, phoneNo: addressBook.phoneNo ?? "")
                output?.didReceiveAddressBookDisplayItem(displayItem)
            } else {
                let storeList = SafetyDataManager.shared.storeBookList
                if let storeBook = StoreBookDTO.storeBookFromAddress(scanValue, array: storeList) {
                    let displayItem = AddressBookDisplayItem(id: storeBook.id ?? 0, name: storeBook.name ?? "", address: storeBook.offchainAddress ?? "", physicalAddress: storeBook.offchainAddress ?? "", isStoreBook: true, phoneNo: storeBook.phoneNo ?? "")
                    output?.didReceiveAddressBookDisplayItem(displayItem)
                } else {
                    output?.didReceiveAddressfromScanner(scanValue)
                }
            }
        }
    }
    
    func sendUserConfirmTransaction(_ transaction: TransactionDTO) {
        let tokenInfo = ModuleDependencies.shared.corePresenter.tokenInfo
        let spendable = tokenInfo?.balance ?? NSNumber(value: 0)
        let outputValue = transaction.outputs?[0].value ?? NSNumber(value: 0)
        if outputValue.compare(spendable) == .orderedDescending {
            output?.didReceiveError("Error: Your spendable is not enough for this.")
            return
        }
        _ = apiManager.transferTransaction(transaction).done { (interTx) in
                // Fix issue: Should keep previous value of transaction
                self.originalTransaction = transaction
                self.transactionData = interTx
                if let pin = self.pinToRetry {
                    self.performTransfer(pin: pin)
                } else {
                    self.requestForPin()
                }
            }.catch({ (error) in
                print("Send create transaction failed, show popup to retry.")
                // Remember original transaction for retrying.
                self.originalTransaction = transaction
                self.output?.performTransferWithError(error as? ConnectionError ?? .systemError, isTransferScreen: false)
            })
    }
    
    func validateTransferTransaction(toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?) {
        let tokenInfo = ModuleDependencies.shared.corePresenter.tokenInfo
        var hasError = false
        
        var isAddressEmpty = false
        var error : String? = nil
        if toAdress == nil || toAdress?.trim() == "" {
            error = "Error: The Receiver Address is not valid."
            isAddressEmpty = true
            hasError = true
            output?.didValidateTransferTransaction(error, isAddress: true)
        }
        if !isAddressEmpty, let trimAddress = toAdress?.trim() {
            if !trimAddress.isEthAddress() {
                error = "Error: The Receiver Address is not valid."
                hasError = true
                output?.didValidateTransferTransaction(error, isAddress: true)
            } else if (tokenInfo?.address?.caseInsensitiveCompare(trimAddress) == .orderedSame) {
                error = "Could not send Mozo to your own wallet"
                hasError = true
                output?.didReceiveError(error)
            }
        }
        
        var isAmountEmpty = false
        let value = amount?.toTextNumberWithoutGrouping()
        if value == nil || value == "" {
            error = "Error".localized + ": " + "Please input amount.".localized
            isAmountEmpty = true
            hasError = true
            output?.didValidateTransferTransaction(error, isAddress: false)
        }
        
        if !isAmountEmpty {
            let spendable = tokenInfo?.balance?.convertOutputValue(decimal: tokenInfo.safeDecimals)
            if spendable! <= 0.0 {
                error = "Error: Your spendable is not enough for this."
                hasError = true
                output?.didValidateTransferTransaction(error, isAddress: false)
            }
            
            if Double(value ?? "0")! > spendable! {
                error = "Error: Your spendable is not enough for this."
                hasError = true
                output?.didValidateTransferTransaction(error, isAddress: false)
            }
            
            if (value?.isValidDecimalMinValue(decimal: tokenInfo.safeDecimals) == false) {
                error = "Error: Amount is too low, please input valid amount."
                hasError = true
                output?.didValidateTransferTransaction(error, isAddress: false)
            }
        }

        if !hasError {
            let tx = createTransactionToTransfer(tokenInfo: tokenInfo, toAdress: toAdress, amount: value)
            output?.continueWithTransaction(tx!, displayContactItem: displayContactItem)
        }
    }
    
    func performTransfer(pin: String) {
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
                    self.output?.didSendTransactionSuccess(receivedTx)
                }).catch({ (err) in
                    print("Send signed transaction failed, show popup to retry.")
                    self.pinToRetry = pin
                    self.output?.performTransferWithError(err as? ConnectionError ?? .systemError, isTransferScreen: false)
                })
            }.catch({ (err) in
                self.output?.didReceiveError(ConnectionError.systemError.localizedDescription)
            })
    }
    
    func requestToRetryTransfer() {
        if let transaction = originalTransaction {
            sendUserConfirmTransaction(transaction)
        }
    }
}
