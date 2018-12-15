//
//  VisitCustomerDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/12/18.
//

import Foundation
import SwiftyJSON
public class VisitCustomerDTO: ResponseObjectSerializable {
    public var visitType: Int?
    public var inStore: Bool?
    public var phoneNo: String?
    public var lastVisitTime: Int64?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.visitType = json["visitType"].int
        self.phoneNo = json["phoneNo"].string
        self.inStore = json["inStore"].bool
        self.lastVisitTime = json["lastVisitTime"].int64
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let visitType = self.visitType {
            json["visitType"] = visitType
        }
        if let phoneNo = self.phoneNo {
            json["phoneNo"] = phoneNo
        }
        if let inStore = self.inStore {
            json["inStore"] = inStore
        }
        if let lastVisitTime = self.lastVisitTime {
            json["lastVisitTime"] = NSNumber(value: lastVisitTime)
        }
        
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [PaymentRequestDTO] {
        let array = json.array?.map({ PaymentRequestDTO(json: $0)! })
        return array ?? []
    }
}
