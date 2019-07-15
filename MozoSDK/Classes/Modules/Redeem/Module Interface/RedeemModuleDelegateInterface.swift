//
//  RedeemModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/11/19.
//

import Foundation
@objc public protocol RedeemPromotionDelegate {
    func redeemPromotionSuccess(promotionPaidDTO: PromotionPaidDTO)
    func redeemPromotionFailureWithErrorString(error: String?)
    func redeemPromotionFailure(error: Error)
}
