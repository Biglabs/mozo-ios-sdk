//
//  CoreInteractor+Promotion.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/3/19.
//

import Foundation
import PromiseKit
extension CoreInteractor {
    func getPromoCreateSetting() -> Promise<PromotionSettingDTO> {
        return apiManager.getPromoCreateSetting()
    }
    
    func createPromotion(_ promotion: PromotionDTO) -> Promise<[String : Any]> {
        return apiManager.createPromotion(promotion)
    }
    
    func getRetailerPromotionList(page: Int, size: Int, statusRequest: PromotionStatusRequestEnum) -> Promise<[PromotionDTO]> {
        return apiManager.getRetailerPromotionList(page: page, size: size, statusRequest: statusRequest)
    }
    
    func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO> {
        return apiManager.processPromotionCode(code: code)
    }
    
    func usePromotionCode(code: String) -> Promise<[String: Any]> {
        return apiManager.usePromotionCode(code: code)
    }
    
    func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return apiManager.cancelPromotionCode(code: code)
    }
    
    func getShopperPromotionListWithType(page: Int, size: Int, long: Double, lat: Double, type: PromotionListTypeEnum) -> Promise<[PromotionStoreDTO]> {
        return apiManager.getShopperPromotionListWithType(page: page, size: size, long: long, lat: lat, type: type)
    }
    
    func getPromotionRedeemInfo(promotionId: Int64) -> Promise<PromotionRedeemInfoDTO> {
        return apiManager.getPromotionRedeemInfo(promotionId: promotionId)
    }
    
    func getPromotionPaidDetail(promotionId: Int64) -> Promise<PromotionPaidDTO> {
        return apiManager.getPromotionPaidDetail(promotionId: promotionId)
    }
    
    func getPromotionPaidDetailByCode(_ promotionCode: String) -> Promise<PromotionPaidDTO> {
        return apiManager.getPromotionPaidDetailByCode(promotionCode)
    }
    
    func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
        return apiManager.updateFavoritePromotion(promotionId, isFavorite: isFavorite)
    }
}
