//
//  CollectionStoreInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/8/19.
//

import Foundation
import SwiftyJSON
public class CollectionStoreInfoDTO: ResponseObjectSerializable {
    public var totalElements: Int64?
    public var stores: [StoreInfoDTO]?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.totalElements = json["totalElements"].int64
        self.stores = json["stores"].array?.filter({ StoreInfoDTO(json: $0) != nil }).map({ StoreInfoDTO(json: $0)! })
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let totalElements = self.totalElements {
            json["totalElements"] = totalElements
        }
        if let stores = self.stores {
            json["stores"] = stores.map({$0.toJSON()})
        }
        return json
    }
}
