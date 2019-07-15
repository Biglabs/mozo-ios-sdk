//
//  PromotionDetailDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/5/19.
//

import Foundation
import SwiftyJSON
public class PromotionDetailDTO {
    public var activationDate: Int64?
    public var promoCode: String?
    public var purchasedTimeSec: Int64?
    public var statusCodeEnum: PromotionStatusCode?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.activationDate = json["activationDate"].int64
        self.purchasedTimeSec = json["purchasedTimeSec"].int64
        self.statusCodeEnum = PromotionStatusCode(rawValue: json["statusCodeEnum"].string ?? "")
        self.promoCode = json["promoCode"].string
    }
}
