//
//  VisitedCustomerDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/17/18.
//

import Foundation
import SwiftyJSON
public class VisitedCustomerDTO: ResponseObjectSerializable {
    public var visitType: Int?
    public var inStore: Bool?
    public var lastVisitedTimeInSec: Int64?
    public var phoneNum: String?
    public var duration: Int64?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.visitType = json["visitType"].int
        self.inStore = json["inStore"].bool
        self.lastVisitedTimeInSec = json["lastVisitedTimeInSec"].int64
        self.phoneNum = json["phoneNum"].string
        self.duration = json["duration"].int64
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let visitType = self.visitType {
            json["visitType"] = visitType
        }
        if let inStore = self.inStore {
            json["inStore"] = inStore
        }
        if let lastVisitedTimeInSec = self.lastVisitedTimeInSec {
            json["lastVisitedTimeInSec"] = lastVisitedTimeInSec
        }
        if let phoneNum = self.phoneNum {
            json["phoneNum"] = phoneNum
        }
        if let duration = self.duration {
            json["duration"] = duration
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [VisitedCustomerDTO] {
        let array = json.array?.map({ VisitedCustomerDTO(json: $0)! })
        return array ?? []
    }
}
