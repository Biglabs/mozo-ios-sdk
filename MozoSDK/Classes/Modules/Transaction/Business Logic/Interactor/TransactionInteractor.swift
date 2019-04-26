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
    var tokenInfo: TokenInfoDTO?
    var pinToRetry: String?
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
    }
    
    func createTransactionToTransfer(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: String?) -> TransactionDTO? {
        let input = InputDTO(addresses: [(tokenInfo?.address)!])!
        let trimToAddress = toAdress?.trimmingCharacters(in: .whitespacesAndNewlines)
        var value = 0.0
        if let amount = amount {
            value = amount.toDoubleValue()
        }
        var txValue = NSNumber(value: 0)
        txValue = value > 0.0 ? value.convertTokenValue(decimal: tokenInfo?.decimals ?? 0) : 0
        
        let output = OutputDTO(addresses: [trimToAddress!], value: txValue)!
        let transaction = TransactionDTO(inputs: [input], outputs: [output])
        
        return transaction
    }
    
    @objc func onUserDidCloseAllMozoUI(_ notification: Notification) {
        print("TransactionInteractor - User close Mozo UI, clear pin cache")
        pinToRetry = nil
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
                let displayItem = AddressBookDisplayItem(id: addressBook.id ?? 0, name: addressBook.name ?? "", address: addressBook.soloAddress ?? "", physicalAddress: "", isStoreBook: false)
                output?.didReceiveAddressBookDisplayItem(displayItem)
            } else {
                let storeList = SafetyDataManager.shared.storeBookList
                if let storeBook = StoreBookDTO.storeBookFromAddress(scanValue, array: storeList) {
                    let displayItem = AddressBookDisplayItem(id: storeBook.id ?? 0, name: storeBook.name ?? "", address: storeBook.offchainAddress ?? "", physicalAddress: storeBook.offchainAddress ?? "", isStoreBook: true)
                    output?.didReceiveAddressBookDisplayItem(displayItem)
                } else {
                    output?.didReceiveAddressfromScanner(scanValue)
                }
            }
        }
    }
    
    func sendUserConfirmTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO) {
        if self.tokenInfo == nil {
            self.tokenInfo = tokenInfo
        }
        let spendable = tokenInfo.balance?.convertOutputValue(decimal: tokenInfo.decimals ?? 0) ?? 0
        if transaction.outputs![0].value?.convertOutputValue(decimal: tokenInfo.decimals ?? 0) ?? 0 > spendable {
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
                    self.output?.requestPinToSignTransaction()
                }
            }.catch({ (error) in
                print("Send create transaction failed, show popup to retry.")
                // Remember original transaction for retrying.
                self.originalTransaction = transaction
                self.output?.performTransferWithError(error as? ConnectionError ?? .systemError, isTransferScreen: false)
            })
    }
    
    func validateTransferTransaction(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?) {
        var hasError = false
        
        var isAddressEmpty = false
        var error : String? = nil
        if toAdress == nil || toAdress?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            error = "Error: The Receiver Address is not valid."
            isAddressEmpty = true
            hasError = true
            output?.didValidateTransferTransaction(error, isAddress: true)
        }
        if !isAddressEmpty, let trimAddress = toAdress?.trimmingCharacters(in: .whitespacesAndNewlines), !trimAddress.isEthAddress() {
            error = "Error: The Receiver Address is not valid."
            hasError = true
            output?.didValidateTransferTransaction(error, isAddress: true)
        }
        
        var isAmountEmpty = false
        let value = amount?.replace(",", withString: ".")
        if value == nil || value == "" {
            error = "Error".localized + ": " + "Please input amount.".localized
            isAmountEmpty = true
            hasError = true
            output?.didValidateTransferTransaction(error, isAddress: false)
        }
        
        if !isAmountEmpty {
            let spendable = tokenInfo?.balance?.convertOutputValue(decimal: tokenInfo?.decimals ?? 0)
            if spendable! <= 0.0 {
                error = "Error: Your spendable is not enough for this."
                output?.didValidateTransferTransaction(error, isAddress: false)
                return
            }
            
            if Double(value ?? "0")! > spendable! {
                error = "Error: Your spendable is not enough for this."
                output?.didValidateTransferTransaction(error, isAddress: false)
                return
            }
            
            if (value?.isValidDecimalMinValue(decimal: tokenInfo?.decimals ?? 0) == false){
                error = "Error: Amount is too low, please input valid amount."
                output?.didValidateTransferTransaction(error, isAddress: false)
                return
            }
        }

        if !hasError {
            let tx = createTransactionToTransfer(tokenInfo: tokenInfo, toAdress: toAdress, amount: value)
            self.tokenInfo = tokenInfo
            output?.continueWithTransaction(tx!, tokenInfo: tokenInfo!, displayContactItem: displayContactItem)
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
                    self.output?.didSendTransactionSuccess(receivedTx, tokenInfo: self.tokenInfo!)
                }).catch({ (err) in
                    print("Send signed transaction failed, show popup to retry.")
                    self.pinToRetry = pin
                    self.output?.performTransferWithError(err as? ConnectionError ?? .systemError, isTransferScreen: false)
                })
            }.catch({ (err) in
                self.output?.didReceiveError(ConnectionError.systemError.localizedDescription)
            })
    }
    
    func loadTokenInfo() {
        if let userObj = SessionStoreManager.loadCurrentUser() {
            if let address = userObj.profile?.walletInfo?.offchainAddress {
                print("Address used to load balance: \(address)")
                _ = apiManager.getTokenInfoFromAddress(address)
                    .done { (tokenInfo) in
                        // TODO: Notify for all observing objects.
                        self.output?.didLoadTokenInfo(tokenInfo)
                    }.catch({ (err) in
                        self.output?.performTransferWithError(err as! ConnectionError, isTransferScreen: true)
                    })
            }
        }
    }
    
    func requestToRetryTransfer() {
        if let transaction = originalTransaction {
            sendUserConfirmTransaction(transaction, tokenInfo: self.tokenInfo!)
        }
    }
}
