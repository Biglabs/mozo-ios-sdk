//
//  RetailerAnalyticsHomeDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/14/18.
//

import Foundation
import SwiftyJSON
public class RetailerAnalyticsHomeDTO: ResponseObjectSerializable {
    public var diffAirdropAmount: NSNumber?
    public var diffCustomerVisited: Int?
    public var newAnalyticData: RetailerCustomerAnalyticDTO?
    public var oldAnalyticData: RetailerCustomerAnalyticDTO?
    public var percentageDiffAirdropAmount: Double?
    public var percentageDiffCustomerVisited: Double?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.diffAirdropAmount = json["diffAirdropAmount"].number
        self.diffCustomerVisited = json["diffCustomerVisited"].int
        self.newAnalyticData = RetailerCustomerAnalyticDTO(json: json["newAnalyticData"])
        self.oldAnalyticData = RetailerCustomerAnalyticDTO(json: json["oldAnalyticData"])
        self.percentageDiffAirdropAmount = json["percentageDiffAirdropAmount"].double
        self.percentageDiffCustomerVisited = json["percentageDiffCustomerVisited"].double
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let diffAirdropAmount = self.diffAirdropAmount {
            json["diffAirdropAmount"] = diffAirdropAmount
        }
        if let diffCustomerVisited = self.diffCustomerVisited {
            json["diffCustomerVisited"] = diffCustomerVisited
        }
        if let percentageDiffAirdropAmount = self.percentageDiffAirdropAmount {
            json["percentageDiffAirdropAmount"] = percentageDiffAirdropAmount
        }
        if let percentageDiffCustomerVisited = self.percentageDiffCustomerVisited {
            json["percentageDiffCustomerVisited"] = percentageDiffCustomerVisited
        }
        if let newAnalyticData = self.newAnalyticData {
            json["percentageDiffAirdropAmount"] = newAnalyticData.toJSON()
        }
        if let oldAnalyticData = self.oldAnalyticData {
            json["oldAnalyticData"] = oldAnalyticData.toJSON()
        }
        return json
    }
}
