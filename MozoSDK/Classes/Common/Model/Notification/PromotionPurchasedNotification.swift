//
//  PromotionPurchasedNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/16/19.
//

import Foundation
import SwiftyJSON
public class PromotionPurchasedNotification : RdNotification {
    public var promoName: String?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.promoName = json["promoName"].string
        super.init(json: json)
    }
}
