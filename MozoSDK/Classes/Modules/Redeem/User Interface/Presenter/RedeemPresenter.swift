//
//  RedeemPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/11/19.
//

import Foundation
import SwiftyJSON
class RedeemPresenter: NSObject {
    var wireframe: RedeemWireframe?
    var interactor: RedeemInteractorInput?
    weak var delegate: RedeemPromotionDelegate?
    
    var eventId: Int64?
    var tokenInfo: TokenInfoDTO?
    
    func redeemPromotion(_ promotionId: Int64) {
        interactor?.redeemPromotion(promotionId)
    }
}
extension RedeemPresenter: PinModuleDelegate {
    func verifiedPINSuccess(_ pin: String) {
        wireframe?.removeDelegateAfterSigning()
        delegate?.showLoading(shouldShow: true)
        interactor?.sendSignedTx(pin: pin)
    }
}
extension RedeemPresenter: RedeemInteractorOutput {
    func requestAutoPINInterface() {
        wireframe?.presentAutoPINInterface(needShowRoot: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS)) {
            self.wireframe?.rootWireframe?.dismissTopViewController()
        }
    }
    
    func failedToRedeemMozoFromEvent(error: String?) {
        delegate?.redeemPromotionFailureWithErrorString(error: error)
    }
    
    func failedToSignTransaction(error: String?) {
        delegate?.redeemPromotionFailureWithErrorString(error: error)
    }
    
    func didFailedToLoadTokenInfo() {
        NSLog("RedeemPresenter - Unable to load token info")
        delegate?.redeemPromotionFailureWithErrorString(error: "Sorry, something went wrong. Please try again or restart the app".localized)
    }
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType, json: JSON) {
        if statusType == .SUCCESS, let promotionPaidDTO = PromotionPaidDTO(json: json) {
            delegate?.redeemPromotionSuccess(promotionPaidDTO: promotionPaidDTO)
            delegate = nil
        } else {
            delegate?.redeemPromotionFailureWithErrorString(error: "Redeem Promotion is failed.")
        }
    }
    
    func didFailedToCreateTransaction(error: ConnectionError) {
        delegate?.redeemPromotionFailure(error: error)
    }
    
    func didSendSignedTransactionFailure(error: ConnectionError) {
        delegate?.redeemPromotionFailure(error: error)
    }
    
    func requestPinInterface() {
        delegate?.showLoading(shouldShow: false)
        wireframe?.presentPinInterface()
    }
}

