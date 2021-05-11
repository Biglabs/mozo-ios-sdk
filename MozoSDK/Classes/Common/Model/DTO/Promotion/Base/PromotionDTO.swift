//
//  PromotionDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/3/19.
//

import Foundation
import SwiftyJSON
public class PromotionDTO {
    public var countActivated: Int64?
    public var countPurchased: Int64?
    public var discountFee: String?
    public var discountPercent: Int?
    public var id: Int64?
    public var imageName: String?
    public var name: String?
    public var periodFromDate: Int64?
    public var periodToDate: Int64?
    public var zoneId: String?
    public var promoStatus: PromotionStatusEnum?
    public var promoType: PromotionTypeEnum?
    public var receivedMozoX: NSNumber?
    public var value: NSNumber?
    public var timeLeftInSecs: Int?
    public var code: String?
    public var limitUser: Int?
    public var remainingNumber: Int?
    public var specialLucky: Bool?
    public var applyManyBranch: Bool?
    public var countOtherBranches: Int?
    
    // MARK: Multiple branches promo
    public var applyBranchIds: [Int64]?
    public var applyBranches: [BranchInfoDTO]?
    public var isManyBranch: Bool?
    public var selectedBranch: BranchInfoDTO? = nil
    
    // MARK: Restriction
    public var target: PromotionTarget = .NONCE
    public var priceOriginal: String?
    public var priceDiscount: String?
    
    // MARK: Appearance of promotion
    public var international: Bool = true
    
    public init() {
        // MARK: empty constructor
    }
    
    public init(
        discountPercent: Int,
        imageName: String,
        name: String,
        periodFromDate: Int64?,
        periodToDate: Int64,
        value: NSNumber,
        promoType: PromotionTypeEnum = .DURATION,
        limitUser: Int?,
        isSpecial: Bool
    ) {
        self.discountPercent = discountPercent
        self.imageName = imageName
        self.name = name
        self.periodFromDate = periodFromDate
        self.periodToDate = periodToDate
        self.value = value
        self.promoType = promoType
        self.limitUser = limitUser
        self.specialLucky = isSpecial
    }
        
    public required init?(json: SwiftyJSON.JSON) {
        self.countActivated = json["countActivated"].int64
        self.countPurchased = json["countPurchased"].int64
        self.discountFee = json["discountFee"].string
        self.discountPercent = json["discountPercent"].int
        self.id = json["id"].int64
        self.imageName = json["imageName"].string
        self.name = json["name"].string
        self.periodFromDate = json["periodFromDate"].int64
        self.periodToDate = json["periodToDate"].int64
        self.zoneId = json["zoneId"].string
        self.promoStatus = PromotionStatusEnum(rawValue: json["promoStatus"].string ?? "")
        self.promoType = PromotionTypeEnum(rawValue: json["promoType"].string ?? "")
        self.receivedMozoX = json["receivedMozoX"].number
        self.value = json["value"].number
        self.timeLeftInSecs = json["timeLeftInSecs"].int
        self.code = json["code"].string
        self.limitUser = json["limitUser"].int
        self.remainingNumber = json["remainingNumber"].int
        self.specialLucky = json["specialLucky"].bool
        self.applyManyBranch = json["applyManyBranch"].bool
        self.applyBranchIds = json["applyBranchIds"].array?.filter({ $0.int64 != nil }).map({ $0.int64! })
        self.applyBranches = BranchInfoDTO.branchArrayFromJson(json["applyBranches"])
        self.countOtherBranches = json["countOtherBranches"].int
        self.isManyBranch = json["isManyBranch"].bool
        self.target = PromotionTarget.init(rawValue: json["targetConsumer"].string ?? PromotionTarget.NONCE.rawValue) ?? .NONCE
        self.international = json["international"].bool ?? true
        self.priceOriginal = json["priceBeforeDiscount"].string
        self.priceDiscount = json["priceAfterDiscount"].string
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let countActivated = self.countActivated {
            json["countActivated"] = countActivated
        }
        if let countPurchased = self.countPurchased {
            json["countPurchased"] = countPurchased
        }
        if let discountFee = self.discountFee {
            json["discountFee"] = discountFee
        }
        if let discountPercent = self.discountPercent {
            json["discountPercent"] = discountPercent
        }
        if let id = self.id {
            json["id"] = id
        }
        if let imageName = self.imageName {
            json["imageName"] = imageName
        }
        if let name = self.name {
            json["name"] = name
        }
        if let periodFromDate = self.periodFromDate {
            json["periodFromDate"] = periodFromDate
        }
        if let periodToDate = self.periodToDate {
            json["periodToDate"] = periodToDate
        }
        if let zoneId = self.zoneId {
            json["zoneId"] = zoneId
        }
        if let promoStatus = self.promoStatus {
            json["promoStatus"] = promoStatus
        }
        if let promoType = self.promoType {
            json["promoType"] = "\(promoType)"
        }
        if let receivedMozoX = self.receivedMozoX {
            json["receivedMozoX"] = receivedMozoX
        }
        if let value = self.value {
            json["value"] = value
        }
        if let limitUser = self.limitUser {
            json["limitUser"] = limitUser
        }
        if let specialLucky = self.specialLucky {
            json["specialLucky"] = specialLucky
        }
        if let applyManyBranch = self.applyManyBranch {
            json["applyManyBranch"] = applyManyBranch
        }
        if let applyBranchIds = self.applyBranchIds {
            json["applyBranchIds"] = applyBranchIds
        }
        if let applyBranches = self.applyBranches {
            json["applyBranches"] = applyBranches.map({$0.toJSON()})
        }
        if let countOtherBranches = self.countOtherBranches {
            json["countOtherBranches"] = countOtherBranches
        }
        if let isManyBranch = self.isManyBranch {
            json["isManyBranch"] = isManyBranch
        }
        
        json["targetConsumer"] = target.rawValue
        json["international"] = self.international
        if let priceOriginal = self.priceOriginal {
            json["priceBeforeDiscount"] = priceOriginal
        }
        if let priceDiscount = self.priceDiscount {
            json["priceAfterDiscount"] = priceDiscount
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [PromotionDTO] {
        let array = json.array?.map({ PromotionDTO(json: $0)! })
        return array ?? []
    }
}
extension PromotionDTO: Equatable {
    public static func == (lhs: PromotionDTO, rhs: PromotionDTO) -> Bool {
        return
            lhs.countActivated == rhs.countActivated &&
            lhs.countPurchased == rhs.countPurchased &&
            lhs.discountFee == rhs.discountFee &&
            lhs.discountPercent == rhs.discountPercent &&
            lhs.id == rhs.id &&
            lhs.imageName == rhs.imageName &&
            lhs.name == rhs.name &&
            lhs.periodFromDate == rhs.periodFromDate &&
            lhs.periodToDate == rhs.periodToDate &&
            lhs.zoneId == rhs.zoneId &&
            lhs.promoStatus == rhs.promoStatus &&
            lhs.promoType == rhs.promoType &&
            lhs.receivedMozoX == rhs.receivedMozoX &&
            lhs.value == rhs.value &&
            lhs.timeLeftInSecs == rhs.timeLeftInSecs &&
            lhs.code == rhs.code &&
            lhs.limitUser == rhs.limitUser &&
            lhs.remainingNumber == rhs.remainingNumber &&
            lhs.specialLucky == rhs.specialLucky &&
            lhs.applyManyBranch == rhs.applyManyBranch &&
            lhs.countOtherBranches == rhs.countOtherBranches &&
            lhs.applyBranchIds == rhs.applyBranchIds &&
            lhs.applyBranches?.count == rhs.applyBranches?.count &&
            lhs.isManyBranch == rhs.isManyBranch &&
        
            lhs.target == rhs.target &&
            lhs.international == rhs.international &&
            lhs.priceOriginal == rhs.priceOriginal &&
            lhs.priceDiscount == rhs.priceDiscount
    }
}
