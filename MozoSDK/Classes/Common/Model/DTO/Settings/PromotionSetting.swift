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
    public var minValueCreation: NSNumber?
    public var maxValueCreation: NSNumber?
    public var canCreateMultiBranch: Bool?
    public var availableBranches: [BranchInfoDTO]?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.discountFee = json["discountFee"].string
        self.discountPercent = json["discountPercent"].int
        self.imageDefaults = json["imageDefaults"].array?.filter({ $0.string != nil }).map({ $0.string! })
        self.numberMozoXRequire = json["numberMozoXRequire"].number
        self.minValueCreation = json["minValueCreation"].number
        self.maxValueCreation = json["maxValueCreation"].number
        self.canCreateMultiBranch = json["canCreateMultiBranch"].bool
        self.availableBranches = BranchInfoDTO.branchArrayFromJson(json["availableBranches"])
    }
    
    public init(dict: Dictionary<String, Any>) {
        self.discountFee = dict["discountFee"] as? String
        self.discountPercent = dict["discountPercent"] as? Int
        self.imageDefaults = dict["imageDefaults"] as? [String]
        self.numberMozoXRequire = dict["numberMozoXRequire"] as? NSNumber
        self.minValueCreation = dict["minValueCreation"] as? NSNumber
        self.maxValueCreation = dict["maxValueCreation"] as? NSNumber
        self.canCreateMultiBranch = dict["canCreateMultiBranch"] as? Bool
        if let raw = dict["availableBranches"] {
            self.availableBranches = BranchInfoDTO.branchArrayFromJson(SwiftyJSON.JSON(raw))
        }
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
        if let minValueCreation = self.minValueCreation {
            json["minValueCreation"] = minValueCreation
        }
        if let maxValueCreation = self.maxValueCreation {
            json["maxValueCreation"] = maxValueCreation
        }
        if let canCreateMultiBranch = self.canCreateMultiBranch {
            json["canCreateMultiBranch"] = canCreateMultiBranch
        }
        if let availableBranches = self.availableBranches {
            json["availableBranches"] = availableBranches.map({$0.toJSON()})
        }
        return json
    }
    
    public func defaultMozoAmount() -> Double {
        let decimals = SessionStoreManager.tokenInfo?.decimals ?? 2
        return numberMozoXRequire?.convertOutputValue(decimal: decimals) ?? 0
    }
    
    public func minMAPS() -> Double {
        let decimals = SessionStoreManager.tokenInfo?.decimals ?? 2
        return (minValueCreation ?? NSNumber(value: 100)).convertOutputValue(decimal: decimals)
    }
    public func maxMAPS() -> Double {
        let decimals = SessionStoreManager.tokenInfo?.decimals ?? 2
        return (maxValueCreation ?? NSDecimalNumber(string: "500000000000")).convertOutputValue(decimal: decimals)
    }
}
