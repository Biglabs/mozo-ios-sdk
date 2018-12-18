//
//  AirdropAddPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
class AirdropAddPresenter: NSObject {
    var wireframe: AirdropAddWireframe?
    var interactor: AirdropAddInteractorInput?
    weak var delegate: AirdropAddEventDelegate?
    
    var airdropEvent: AirdropEventDTO?
    var tokenInfo: TokenInfoDTO?
    
    func addMoreMozoToEvent(_ event: AirdropEventDTO) {
        interactor?.addMoreMozoToEvent(event)
    }
}
extension AirdropAddPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        interactor?.sendSignedTx(pin: pin)
    }
}
extension AirdropAddPresenter: AirdropAddInteractorOutput {
    func failedToAddMozoToAirdropEvent(error: String?) {
        delegate?.addMozoToAirdropEventFailure(error: error)
    }
    
    func failedToSignTransaction(error: String?) {
        delegate?.addMozoToAirdropEventFailure(error: error)
    }
    
    func didFailedToLoadTokenInfo() {
        delegate?.addMozoToAirdropEventFailure(error: "Unable to load tokenInfo.")
    }
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType) {
        if statusType == .SUCCESS {
            delegate?.addMozoToAirdropEventSuccess()
            delegate = nil
        } else {
            delegate?.addMozoToAirdropEventFailure(error: "Add more Mozo to airdrop event is failed to created.")
        }
    }
    
    func didSendSignedTransactionFailure(error: ConnectionError) {
        delegate?.addMozoToAirdropEventFailure(error: error.errorDescription)
    }
    
    func requestPinInterface() {
        wireframe?.presentPinInterface()
    }
}
