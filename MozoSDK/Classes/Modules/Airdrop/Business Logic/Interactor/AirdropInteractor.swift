//
//  AirdropInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
class AirdropInteractor: NSObject {
    var output: AirdropInteractorOutput?
    var signManager : TransactionSignManager?
    var apiManager: ApiManager?
    var transactionData : IntermediaryTransactionDTO?
    var pinToRetry: String?
}
extension AirdropInteractor: AirdropInteractorInput {
    func sendCreateAirdropEvent(_ event: AirdropEventDTO) {
        _ = apiManager?.createAirdropEvent(event: event).done({ (interTx) in
            if (interTx.errors != nil) && (interTx.errors?.count)! > 0 {
                self.output?.failedToCreateAirdropEvent(error: interTx.errors?.first)
            } else {
                self.transactionData = interTx
                if let pin = self.pinToRetry {
                    self.sendSignedAirdropEventTx(pin: pin)
                } else {
                    self.output?.requestPinInterface()
                }
            }
        }).catch({ (error) in
            let cErr = error as! ConnectionError
            self.output?.failedToCreateAirdropEvent(error: cErr.errorDescription)
        })        
    }
    
    func sendSignedAirdropEventTx(pin: String) {
        signManager?.signTransaction(transactionData!, pin: pin)
            .done { (signedInterTx) in
                self.apiManager?.sendSignedAirdropEventTx(signedInterTx).done({ (receivedTx) in
                    print("Send successfully with hash: \(receivedTx.tx?.hash ?? "NULL")")
                    // Clear retry PIN
                    self.clearRetryPin()
                    self.output?.didCreateAndSignAirdropEventSuccess()
                }).catch({ (err) in
                    print("Send signed transaction failed, show popup to retry.")
                    self.pinToRetry = pin
                    self.output?.didSendSignedAirdropEventFailure(error: err as! ConnectionError)
                })
            }.catch({ (err) in
                self.output?.failedToSignAirdropEvent(error: err.localizedDescription)
            })
    }
    
    func clearRetryPin() {
        self.pinToRetry = nil
    }
}
