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
    
    public override func toJSON() -> Dictionary<String, Any> {
        var json = super.toJSON()
        if let from = self.from {
            json["from"] = from
        }
        if let to = self.to {
            json["to"] = to
        }
        if let amount = self.amount {
            json["amount"] = amount
        }
        if let symbol = self.symbol {
            json["symbol"] = symbol
        }
        if let decimal = self.decimal {
            json["decimal"] = decimal
        }
        return json
    }
}
