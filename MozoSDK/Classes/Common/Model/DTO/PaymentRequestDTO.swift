//
//  PaymentRequestDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
import SwiftyJSON
public class PaymentRequestDTO: ResponseObjectSerializable {
    public var id: Int64?
    public var requestingAddress: String?
    public var amount: NSNumber?
    public var decimal: Int64?
    public var symbol: String?
    public var date: Int64?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].int64
        self.requestingAddress = json["requestingAddress"].string
        self.amount = json["amount"].number
        self.decimal = json["decimal"].int64
        self.symbol = json["symbol"].string
        self.date = json["date"].int64
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let id = self.id {
            json["id"] = id
        }
        if let requestingAddress = self.requestingAddress {
            json["requestingAddress"] = requestingAddress
        }
        if let amount = self.amount {
            json["amount"] = amount
        }
        
        if let decimal = self.decimal {
            json["decimal"] = NSNumber(value: decimal)
        }
        
        if let symbol = self.symbol {
            json["symbol"] = symbol
        }
        
        if let date = self.date {
            json["date"] = NSNumber(value: date)
        }

        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [PaymentRequestDTO] {
        let array = json.array?.map({ PaymentRequestDTO(json: $0)! })
        return array ?? []
    }
}
