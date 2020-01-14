//
//  PromotionStoreGroupDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/26/19.
//

import Foundation
import SwiftyJSON
public class PromotionStoreGroupDTO {
    public var promotionCount: Int?
    public var distance: Double?
    public var storeInfo: StoreInfoDTO?
    
    public var supportParking: Bool?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.promotionCount = json["promotionCount"].int
        self.distance = json["distance"].double
        self.storeInfo = StoreInfoDTO(json: json["storeInfo"])
        
        self.supportParking = json["supportParking"].bool
    }
    
    public static func arrayFrom(_ json: SwiftyJSON.JSON) -> [PromotionStoreGroupDTO] {
        let array = json.array?.map({ PromotionStoreGroupDTO(json: $0)! })
        return array ?? []
    }
}
