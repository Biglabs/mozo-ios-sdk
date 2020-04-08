//
//  PromotionPaidDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/11/19.
//

import Foundation
import SwiftyJSON
@objc public class PromotionPaidDTO: NSObject {
    public var detail: PromotionDetailDTO?
    public var promo: PromotionDTO?
    public var branch: BranchInfoDTO?
    public var statusTxHash: TransactionStatusType?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.detail = PromotionDetailDTO(json: json["detail"])
        self.promo = PromotionDTO(json: json["promo"])
        self.statusTxHash = TransactionStatusType(rawValue: json["statusTxHash"].string ?? "")
        
        self.branch = BranchInfoDTO(json: json["branch"])
    }
}
