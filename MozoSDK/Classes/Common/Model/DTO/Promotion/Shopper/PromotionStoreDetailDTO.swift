//
//  PromotionStoreDetailDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/9/19.
//

import Foundation
import SwiftyJSON
public class PromotionStoreDetailDTO {
    public var activationDate: Int64?
    public var idDetail: Int64?
    public var purchased: Bool?
    public var saved: Bool?
    public var status: PromotionStatusRequestEnum?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.activationDate = json["activationDate"].int64
        self.idDetail = json["idDetail"].int64
        self.status = PromotionStatusRequestEnum(rawValue: json["status"].string ?? "")
        self.purchased = json["purchased"].bool
        self.saved = json["saved"].bool
    }
}
