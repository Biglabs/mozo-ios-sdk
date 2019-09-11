//
//  CollectionPromotionInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/11/19.
//

import Foundation
import SwiftyJSON
public class CollectionPromotionInfoDTO: ResponseObjectSerializable {
    public var totalItems: Int64?
    public var items: [PromotionStoreDTO]?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.totalItems = json["totalItems"].int64
        self.items = json["items"].array?.filter({ PromotionStoreDTO(json: $0) != nil }).map({ PromotionStoreDTO(json: $0)! })
    }
    
    public required init?(){}
}
