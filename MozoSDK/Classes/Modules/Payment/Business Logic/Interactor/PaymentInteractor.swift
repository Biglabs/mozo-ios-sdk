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
}
extension PaymentInteractor : PaymentInteractorInput {
    func validateValueFromScanner(_ scanValue: String) {
        if scanValue.isValidReceiveFormat() {
            
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
        output?.finishGetListPaymentRequest([], forPage: 0)
        return
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
