//
//  PromotionDetailDTO.swift
//  MozoSDK
//
//  Created by MAC on 26/01/2022.
//

import Foundation
import SwiftyJSON
public class PromotionDetailDTO {
    public var activationDate: Int64?
    public var promoCode: String?
    public var promoCustomCode: String?
    public var purchasedTimeSec: Int64?
    public var statusCodeEnum: PromoStatusCode?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.activationDate = json["activationDate"].int64
        self.purchasedTimeSec = json["purchasedTimeSec"].int64
        self.statusCodeEnum = PromoStatusCode(rawValue: json["statusCodeEnum"].string ?? "")
        self.promoCode = json["promoCode"].string
        self.promoCustomCode = json["promoCustomCode"].string
    }
}
