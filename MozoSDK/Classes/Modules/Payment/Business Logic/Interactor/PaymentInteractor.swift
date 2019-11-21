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
        let txValue = NSDecimalNumber(decimal: item.amount.decimalValue).multiplying(byPowerOf10: Int16(tokenInfo.decimals ?? 0))
        
        let output = OutputDTO(addresses: [trimToAddress], value: txValue)!
        let transaction = TransactionDTO(inputs: [input], outputs: [output])
        
        return transaction!
    }
    
    func validateRequest(_ request: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO) -> String?{
//        let spendable = tokenInfo.balance?.convertOutputValue(decimal: tokenInfo.decimals ?? 0)
//        if spendable! <= 0.0 || request.amount > spendable! {
//            return "Error: Your spendable is not enough for this."
//        }
        if ("\(request.amount)".isValidDecimalMinValue(decimal: tokenInfo.decimals ?? 0) == false){
            return "Error: Amount is too low, please input valid amount."
        }
        return nil
    }
    
    func performPaymentTransaction(request: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO, isFromScannedValue: Bool = false) {
        let tx = createTransaction(tokenInfo: tokenInfo, item: request)
        let displayContactItem = DisplayUtils.buildContactDisplayItem(address: request.requestingAddress)
        output?.didReceiveTransaction(transaction: tx, displayContactItem: displayContactItem, isFromScannedValue: isFromScannedValue)
    }
}
extension PaymentInteractor : PaymentInteractorInput {
    func deletePaymentRequest(_ request: PaymentRequestDisplayItem) {
        _ = apiManager.deletePaymentRequest(requestId: request.id).done({ (result) in
            self.output?.didDeletePaymentRequestSuccess()
        }).catch({ (error) in
            self.output?.errorWhileDeleting(error)
        })
    }
    
    func prepareTransactionFromRequest(_ request: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO) {
//        if let errorMsg = validateRequest(request, tokenInfo: tokenInfo) {
//            output?.didReceiveError(errorMsg)
//        } else {
            performPaymentTransaction(request: request, tokenInfo: tokenInfo)
//        }
    }
    
    func validateValueFromScanner(_ scanValue: String, tokenInfo: TokenInfoDTO) {
        if scanValue.isValidReceiveFormat() {
            let item = PaymentRequestDisplayItem(scheme: scanValue)
            if let errorMsg = validateRequest(item, tokenInfo: tokenInfo) {
                output?.didReceiveErrorString(errorMsg)
            } else {
                performPaymentTransaction(request: item, tokenInfo: tokenInfo, isFromScannedValue: true)
            }
        } else {
            output?.didReceiveErrorString("Scanned value is invalid.")
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
                        self.output?.errorWhileLoadingTokenInfo(err as? ConnectionError ?? .systemError)
                    })
            }
        }
    }
    
    func getListPaymentRequest(page: Int = 0) {
        _ = apiManager.getListPaymentRequest(page: page)
            .done { (listPayment) in
                self.output?.finishGetListPaymentRequest(listPayment, forPage: page)
            }.catch { (error) in
                self.output?.errorWhileLoadPaymentRequest(error as! ConnectionError)
        }
    }
}
