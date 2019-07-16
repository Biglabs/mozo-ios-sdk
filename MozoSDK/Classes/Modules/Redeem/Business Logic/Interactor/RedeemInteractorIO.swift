//
//  RedeemInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/11/19.
//

import Foundation
import SwiftyJSON
protocol RedeemInteractorInput {
    func redeemPromotion(_ promotionId: Int64)
    func sendSignedTx(pin: String)
}
protocol RedeemInteractorOutput {
    func didFailedToLoadTokenInfo()
    func failedToRedeemMozoFromEvent(error: String?)
    func failedToSignTransaction(error: String?)
    
    func didFailedToCreateTransaction(error: ConnectionError)
    func didSendSignedTransactionFailure(error: ConnectionError)
    func requestPinInterface()
    
    func didReceiveTxStatus(_ statusType: TransactionStatusType, json: JSON)
    
    func requestAutoPINInterface()
}
