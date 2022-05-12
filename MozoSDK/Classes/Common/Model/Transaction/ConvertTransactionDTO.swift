//
//  ConvertTransactionDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/10/19.
//

import Foundation
import SwiftyJSON

public class ConvertTransactionDTO {
    public var fromAddress: String?
    public var gasLimit: NSNumber?
    public var gasPrice: NSNumber?
    public var toAddress: String?
    public var value: NSNumber?
    
    public init?(fromAddress: String, gasLimit: NSNumber, gasPrice: NSNumber,
                 toAddress: String, value: NSNumber){
        self.fromAddress = fromAddress
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.toAddress = toAddress
        self.value = value
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.fromAddress = json["fromAddress"].string
        self.gasLimit = json["gasLimit"].number
        self.gasPrice = json["gasPrice"].number
        self.toAddress = json["toAddress"].string
        self.value = json["value"].number
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let fromAddress = self.fromAddress {
            json["fromAddress"] = fromAddress
        }
        if let gasLimit = self.gasLimit {
            json["gasLimit"] = gasLimit
        }
        if let gasPrice = self.gasPrice {
            json["gasPrice"] = gasPrice
        }
        if let toAddress = self.toAddress {
            json["toAddress"] = toAddress
        }
        if let value = self.value {
            json["value"] = value
        }
        return json
    }
}
