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
    
    func cancel() {
    }
}
extension AirdropAddPresenter: AirdropAddInteractorOutput {
    func requestAutoPINInterface() {
        wireframe?.presentAutoPINInterface(needShowRoot: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS)) {
            self.wireframe?.rootWireframe?.dismissTopViewController()
        }
    }
    
    func failedToAddMozoToAirdropEvent(error: String?) {
        delegate?.addMozoToAirdropEventFailureWithErrorString(error: error)
    }
    
    func failedToSignTransaction(error: String?) {
        delegate?.addMozoToAirdropEventFailureWithErrorString(error: error)
    }
    
    func didFailedToLoadTokenInfo() {
        NSLog("AirdropAddPresenter - Unable to load token info")
        delegate?.addMozoToAirdropEventFailureWithErrorString(error: "Sorry, something went wrong. Please try again or restart the app".localized)
    }
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType) {
        if statusType == .SUCCESS {
            delegate?.addMozoToAirdropEventSuccess()
            delegate = nil
        } else {
            delegate?.addMozoToAirdropEventFailureWithErrorString(error: "Add more Mozo to airdrop event is failed to created.")
        }
    }
    
    func didFailedToCreateTransaction(error: ConnectionError) {
        delegate?.addMozoToAirdropEventFailure(error: error)
    }
    
    func didSendSignedTransactionFailure(error: ConnectionError) {
        delegate?.addMozoToAirdropEventFailure(error: error)
    }
    
    func requestPinInterface() {
        wireframe?.presentPinInterface()
    }
}
