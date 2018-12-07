//
//  PaymentInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
class PaymentInteractor: NSObject {
    var output: PaymentInteractorOutput?
    let apiManager : ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func createTransaction(tokenInfo: TokenInfoDTO, item: PaymentRequestDisplayItem) -> TransactionDTO {
        let toAddress = item.requestingAddress
        let input = InputDTO(addresses: [tokenInfo.address!])!
        let trimToAddress = toAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = item.amount
        let value = Double(amount)
        var txValue = NSNumber(value: 0)
        txValue = value > 0.0 ? value.convertTokenValue(decimal: tokenInfo.decimals ?? 0) : 0
        
        let output = OutputDTO(addresses: [trimToAddress], value: txValue)!
        let transaction = TransactionDTO(inputs: [input], outputs: [output])
        
        return transaction!
    }
    
    func validateRequest(_ request: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO) -> String?{
        let spendable = tokenInfo.balance?.convertOutputValue(decimal: tokenInfo.decimals ?? 0)
        if spendable! <= 0.0 || request.amount > spendable! {
            return "Error: Your spendable is not enough for this."
        }
        if ("\(request.amount)".isValidDecimalMinValue(decimal: tokenInfo.decimals ?? 0) == false){
            return "Error: Amount is too low, please input valid amount."
        }
        return nil
    }
    
    func performPaymentTransaction(request: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO, isFromScannedValue: Bool = false) {
        let tx = createTransaction(tokenInfo: tokenInfo, item: request)
        let name = DisplayUtils.buildNameFromAddress(address: request.requestingAddress)
        output?.didReceiveTransaction(transaction: tx, displayName: name == request.requestingAddress ? nil : name, isFromScannedValue: isFromScannedValue)
    }
}
extension PaymentInteractor : PaymentInteractorInput {
    func prepareTransactionFromRequest(_ request: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO) {
        if let errorMsg = validateRequest(request, tokenInfo: tokenInfo) {
            output?.didReceiveError(errorMsg)
        } else {
            performPaymentTransaction(request: request, tokenInfo: tokenInfo)
        }
    }
    
    func validateValueFromScanner(_ scanValue: String, tokenInfo: TokenInfoDTO) {
        if scanValue.isValidReceiveFormat() {
            let item = PaymentRequestDisplayItem(scheme: scanValue)
            if let errorMsg = validateRequest(item, tokenInfo: tokenInfo) {
                output?.didReceiveError(errorMsg)
            } else {
                performPaymentTransaction(request: item, tokenInfo: tokenInfo, isFromScannedValue: true)
            }
        } else {
            output?.didReceiveError("Scanned value is invalid.")
        }
    }
    
    func loadTokenInfo() {
        if let userObj = SessionStoreManager.loadCurrentUser() {
            if let address = userObj.profile?.walletInfo?.offchainAddress {
                print("Address used to load balance: \(address)")
                _ = apiManager.getTokenInfoFromAddress(address)
                    .done { (tokenInfo) in
                        self.output?.didLoadTokenInfo(tokenInfo)
                    }.catch({ (err) in
                        self.output?.didReceiveError(err.localizedDescription)
                    })
            }
        }
    }
    
    func getListPaymentRequest(page: Int = 0) {
        if let userObj = SessionStoreManager.loadCurrentUser(),
            let address = userObj.profile?.walletInfo?.offchainAddress {
            print("Address used to load list payment request: \(address)")
            apiManager.getListPaymentRequest(address: address, page: page)
                .done { (listPayment) in
                    self.output?.finishGetListPaymentRequest(listPayment, forPage: page)
                }.catch { (error) in
                    self.output?.errorWhileLoadPaymentRequest(error as! ConnectionError)
            }
        }
    }
}
