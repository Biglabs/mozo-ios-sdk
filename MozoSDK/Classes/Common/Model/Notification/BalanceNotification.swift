//
//  BalanceNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/16/18.
//

import Foundation
import SwiftyJSON

public class BalanceNotification : RdNotification {
    public var from: String?
    public var to: String?
    public var amount: NSNumber?
    public var symbol: String?
    public var decimal: Int?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.from = json["from"].string
        self.to = json["to"].string
        self.amount = json["amount"].number
        self.symbol = json["symbol"].string
        self.decimal = json["decimal"].int
        super.init(json: json)
    }
}
