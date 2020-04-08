//
//  PromotionStoreDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/9/19.
//

import Foundation
import SwiftyJSON
public class PromotionStoreDTO {
    public var detail: PromotionStoreDetailDTO?
    public var promo: PromotionDTO?
    public var branch: BranchInfoDTO?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.detail = PromotionStoreDetailDTO(json: json["detail"])
        self.promo = PromotionDTO(json: json["promo"])
        self.branch = BranchInfoDTO(json: json["branch"])
    }
    
    public static func arrayFrom(_ json: SwiftyJSON.JSON) -> [PromotionStoreDTO] {
        let array = json.array?.map({ PromotionStoreDTO(json: $0)! })
        return array ?? []
    }
}
