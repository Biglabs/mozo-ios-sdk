//
//  PromotionCodeInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/8/19.
//

import Foundation
import SwiftyJSON
public class PromotionCodeInfoDTO {
    public var detail: PromotionDetailDTO?
    public var promo: PromotionDTO?
    public var userInfo: UserProfileDTO?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.detail = PromotionDetailDTO(json: json["detail"])
        self.promo = PromotionDTO(json: json["promo"])
        self.userInfo = UserProfileDTO(json: json["userInfo"])
    }
}
