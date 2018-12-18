//
//  AirdropNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/16/18.
//

import Foundation
import SwiftyJSON

public class AirdropNotification : BalanceNotification {
    public var storeName: String?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.storeName = json["storeName"].string
        super.init(json: json)
    }
}
