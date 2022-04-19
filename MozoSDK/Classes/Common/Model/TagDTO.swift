//
//  TagDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 2/12/19.
//

import Foundation
import SwiftyJSON

public class TagDTO: ResponseObjectSerializable {
    public var id: Int64?
    public var hashTag: String?
    public var tenantId: Int64?
    public var isDefault: Bool?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].int64
        self.hashTag = json["hashTag"].string
        self.tenantId = json["tenantId"].int64
        self.isDefault = json["isDefault"].bool
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let id = self.id {
            json["id"] = id
        }
        if let hashTag = self.hashTag {
            json["hashTag"] = hashTag
        }
        if let tenantId = self.tenantId {
            json["tenantId"] = tenantId
        }
        if let isDefault = self.isDefault {
            json["isDefault"] = isDefault
        }
        return json
    }
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [TagDTO] {
        let array = json.array?.map({ TagDTO(json: $0)! })
        return array ?? []
    }
    
    public static func extractHashtagFromDTO(tagDTOs: [TagDTO]) -> [String] {
        let array = tagDTOs.filter({ $0.hashTag != nil && !(($0.hashTag ?? "").isEmpty) }).map { return $0.hashTag ?? "" }
        return array
    }
}
