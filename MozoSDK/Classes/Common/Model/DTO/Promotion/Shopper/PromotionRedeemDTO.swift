//
//  PromotionRedeemDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/14/19.
//

import Foundation
import SwiftyJSON
@objc public class PromotionRedeemDTO: NSObject {
    public var idRaw: Int64?
    public var itx: IntermediaryTransactionDTO?
    
    public init(idRaw: Int64, signedTx: IntermediaryTransactionDTO) {
        self.idRaw = idRaw
        self.itx = signedTx
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.idRaw = json["idRaw"].int64
        self.itx = IntermediaryTransactionDTO(json: json["itx"])
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let idRaw = self.idRaw {
            json["idRaw"] = idRaw
        }
        if let itx = self.itx {
            json["itx"] = itx.toJSON()
        }
        return json
    }
}
