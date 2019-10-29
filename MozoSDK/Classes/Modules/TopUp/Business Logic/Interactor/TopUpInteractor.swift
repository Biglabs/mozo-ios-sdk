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
    var apiManager: ApiManager?
}
extension TopUpInteractor: TopUpInteractorInput {
    func clearRetryPin() {
        
    }
    
    func sendSignedTopUpTx(pin: String) {
        
    }
    
    func prepareTopUp(_ transaction: TransactionDTO) {
        
    }
}
