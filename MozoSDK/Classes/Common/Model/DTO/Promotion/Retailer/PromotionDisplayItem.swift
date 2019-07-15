//
//  PromotionDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/5/19.
//

import Foundation
public class PromotionDisplayItem {
    public var countActivated: Int64
    public var countPurchased: Int64
    public var discountFee: String
    public var discountPercent: Int
    public var id: Int64
    public var imageName: String
    public var name: String
    public var periodFromDate: Int64
    public var periodToDate: Int64
    public var promoStatus: PromotionStatusEnum
    public var promoType: PromotionTypeEnum
    public var receivedMozoX: NSNumber
    public var value: NSNumber
    public var timeLeftInSecs: Int
    
    public init() {
        self.countActivated = 0
        self.countPurchased = 0
        self.discountFee = ""
        self.discountPercent = 0
        self.id = 0
        self.imageName = ""
        self.name = ""
        self.periodFromDate = 0
        self.periodToDate = 0
        self.promoStatus = PromotionStatusEnum.END
        self.promoType = PromotionTypeEnum.DURATION
        self.receivedMozoX = NSNumber(value: 0)
        self.value = NSNumber(value: 0)
        self.timeLeftInSecs = 0
    }
    
    public init(promotionDTO: PromotionDTO) {
        self.countActivated = promotionDTO.countActivated ?? 0
        self.countPurchased = promotionDTO.countPurchased ?? 0
        self.discountFee = promotionDTO.discountFee ?? ""
        self.discountPercent = promotionDTO.discountPercent ?? 0
        self.id = promotionDTO.id ?? 0
        self.imageName = promotionDTO.imageName ?? ""
        self.name = promotionDTO.name ?? ""
        self.periodFromDate = promotionDTO.periodFromDate ?? 0
        self.periodToDate = promotionDTO.periodToDate ?? 0
        self.promoStatus = promotionDTO.promoStatus ?? PromotionStatusEnum.END
        self.promoType = promotionDTO.promoType ?? PromotionTypeEnum.DURATION
        self.receivedMozoX = promotionDTO.receivedMozoX ?? NSNumber(value: 0)
        self.value = promotionDTO.value ?? NSNumber(value: 0)
        self.timeLeftInSecs = promotionDTO.timeLeftInSecs ?? 0
    }
    
    public var dateFromTo: String {
        let dateFormat = "MMM d".localized
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        let fromDate = Date(timeIntervalSince1970: TimeInterval(periodFromDate))
        let fromDateText = formatter.string(from: fromDate).uppercased()
        
        let toDate = Date(timeIntervalSince1970: TimeInterval(periodToDate))
        let toDateText = formatter.string(from: toDate).uppercased()
        
        return "\(fromDateText) - \(toDateText)"
    }
    
    public var dayLeftText: String {
        return "(\("%d days left".localizedFormat(self.dayLeft)))"
    }
    
    public var dayLeftFromNowText: String {
        return "(\("%d days left".localizedFormat(self.dayLeftFromNow)))"
    }
    
    public func dayLeftFromNowTextWithFormat(_ format: String = "%d days left") -> String {
        return "(\(format.localizedFormat(self.dayLeftFromNow)))"
    }
    
    public var dayLeft: Int {
        let fromDate = Date(timeIntervalSince1970: TimeInterval(periodFromDate))
        
        let toDate = Date(timeIntervalSince1970: TimeInterval(periodToDate))
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        return abs(components.day ?? 0) + 1
    }
    
    public var dayLeftFromNow: Int {
        let fromDate = Date()
        
        let toDate = Date(timeIntervalSince1970: TimeInterval(periodToDate))
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        return abs(components.day ?? 0) + 1
    }
    
    public var percentOffText: String {
        return "%d%% OFF".localizedFormat(discountPercent)
    }
    
    public var mozoXRequireDouble: Double {
        let decimals = SessionStoreManager.tokenInfo?.decimals ?? 2
        return self.value.convertOutputValue(decimal: decimals)
    }
    
    public var mozoXRequireText: String {
        return self.mozoXRequireDouble.addCommas()
    }
    
    public var mozoXRequireExchangeText: String {
        return DisplayUtils.getExchangeTextFromAmount(self.mozoXRequireDouble)
    }
}
