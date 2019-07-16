//
//  PromotionUsedNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/16/19.
//

import Foundation
import SwiftyJSON
public class PromotionUsedNotification : RdNotification {
    public var storeName: String?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.storeName = json["storeName"].string
        super.init(json: json)
    }
}
