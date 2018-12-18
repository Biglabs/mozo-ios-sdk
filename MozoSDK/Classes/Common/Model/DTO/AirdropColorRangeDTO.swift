//
//  AirdropColorRangeDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/14/18.
//

import Foundation
import SwiftyJSON

public class AirdropColorRangeDTO : ResponseObjectSerializable {
    public var min: Int64?
    public var max: Int64?
    public var color: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.color = json["color"].string
        self.min = json["min"].int64
        self.max = json["max"].int64
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let color = self.color {
            json["color"] = color
        }
        if let min = self.min {
            json["min"] = min
        }
        if let max = self.max {
            json["max"] = max
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [AirdropColorRangeDTO] {
        let array = json.array?.map({ AirdropColorRangeDTO(json: $0)! })
        return array ?? []
    }
}
