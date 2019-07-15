//
//  RedeemWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/11/19.
//

import Foundation
class RedeemWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var redeemPresenter: RedeemPresenter?
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func requestToRedeemAndSign(_ promotionId: Int64, delegate: RedeemPromotionDelegate) {
        redeemPresenter?.delegate = delegate
        redeemPresenter?.redeemPromotion(promotionId)
    }
    
    func presentPinInterface() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = redeemPresenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.Redeem)
    }
}
