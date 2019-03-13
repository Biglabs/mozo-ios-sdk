//
//  GasPriceDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
import SwiftyJSON

public class GasPriceDTO: ResponseObjectSerializable {
    public var low: NSNumber?
    public var average: NSNumber?
    public var fast: NSNumber?
    public var gasLimit: NSNumber?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.low = json["low"].number
        self.average = json["average"].number
        self.fast = json["fast"].number
        self.gasLimit = json["gasLimit"].number
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let low = self.low {
            json["low"] = low
        }
        if let average = self.average {
            json["average"] = average
        }
        if let fast = self.fast {
            json["fast"] = fast
        }
        if let gasLimit = self.gasLimit {
            json["gasLimit"] = gasLimit
        }
        return json
    }
}
