//
//  AirdropEventDiscoverDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/13/19.
//

import Foundation
import SwiftyJSON

public class AirdropEventDiscoverDTO {
    public var eventId: Int64?
    public var eventDisable: Bool?
    public var eventName: String?
    public var customerAirdropAmount: NSNumber?
    public var eventLatitude: Double?
    public var eventLongitude: Double?
    public var eventDistance: Double?
    public var nextReceiveTime: Int64?
    public var storeInfo: StoreInfoDTO?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.eventId = json["eventId"].int64
        self.eventDisable = json["eventDisable"].bool
        self.eventName = json["eventName"].string
        self.customerAirdropAmount = json["customerAirdropAmount"].number
        self.eventLatitude = json["eventLatitude"].double
        self.eventLongitude = json["eventLongitude"].double
        self.eventDistance = json["eventDistance"].double
        self.nextReceiveTime = json["nextReceiveTime"].int64
        self.storeInfo = StoreInfoDTO(json: json["storeInfo"])
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let eventId = self.eventId {
            json["eventId"] = eventId
        }
        if let eventDisable = self.eventDisable {
            json["eventDisable"] = eventDisable
        }
        if let eventName = self.eventName {
            json["eventName"] = eventName
        }
        if let customerAirdropAmount = self.customerAirdropAmount {
            json["customerAirdropAmount"] = customerAirdropAmount
        }
        if let eventLatitude = self.eventLatitude {
            json["eventLatitude"] = eventLatitude
        }
        if let eventLongitude = self.eventLongitude {
            json["eventLongitude"] = eventLongitude
        }
        if let eventDistance = self.eventDistance {
            json["eventDistance"] = eventDistance
        }
        if let nextReceiveTime = self.nextReceiveTime {
            json["nextReceiveTime"] = nextReceiveTime
        }
        if let storeInfo = self.storeInfo {
            json["storeInfo"] = storeInfo.toJSON()
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [AirdropEventDiscoverDTO] {
        let array = json.array?.map({ AirdropEventDiscoverDTO(json: $0)! })
        return array ?? []
    }
}
