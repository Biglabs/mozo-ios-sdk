//
//  PromotionSetting.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/3/19.
//

import Foundation
import SwiftyJSON

public class PromotionSettingDTO : ResponseObjectSerializable {
    public var discountFee: String?
    public var discountPercent: Int?
    public var imageDefaults: [String]?
    public var numberMozoXRequire: NSNumber?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.discountFee = json["discountFee"].string
        self.discountPercent = json["discountPercent"].int
        self.imageDefaults = json["imageDefaults"].array?.filter({ $0.string != nil }).map({ $0.string! })
        self.numberMozoXRequire = json["numberMozoXRequire"].number
    }
    
    public init(dict: Dictionary<String, Any>) {
        self.discountFee = dict["discountFee"] as? String
        self.discountPercent = dict["discountPercent"] as? Int
        self.imageDefaults = dict["imageDefaults"] as? [String]
        self.numberMozoXRequire = dict["numberMozoXRequire"] as? NSNumber
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let discountFee = self.discountFee {
            json["discountFee"] = discountFee
        }
        if let discountPercent = self.discountPercent {
            json["discountPercent"] = discountPercent
        }
        if let imageDefaults = self.imageDefaults {
            json["imageDefaults"] = imageDefaults
        }
        if let numberMozoXRequire = self.numberMozoXRequire {
            json["numberMozoXRequire"] = numberMozoXRequire
        }
        return json
    }
}
