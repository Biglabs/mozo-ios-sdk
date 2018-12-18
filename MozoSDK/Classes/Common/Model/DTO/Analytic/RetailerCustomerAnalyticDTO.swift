//
//  RetailerCustomerAnalyticDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/14/18.
//

import Foundation
import SwiftyJSON
public class RetailerCustomerAnalyticDTO: ResponseObjectSerializable {
    public var airDropAmount: NSNumber?
    public var numberOfCustomerVisit: Int?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.airDropAmount = json["airDropAmount"].number
        self.numberOfCustomerVisit = json["numberOfCustomerVisit"].int
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let airDropAmount = self.airDropAmount {
            json["airDropAmount"] = airDropAmount
        }
        if let numberOfCustomerVisit = self.numberOfCustomerVisit {
            json["numberOfCustomerVisit"] = numberOfCustomerVisit
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [RetailerCustomerAnalyticDTO] {
        let array = json.array?.map({ RetailerCustomerAnalyticDTO(json: $0)! })
        return array ?? []
    }
}
