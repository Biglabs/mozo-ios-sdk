//
//  CoreInteractor+Promotion.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/3/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
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
    
    func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO> {
        return apiManager.usePromotionCode(code: code, billInfo: billInfo)
    }
    
    func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return apiManager.cancelPromotionCode(code: code)
    }
    
    func getShopperPromotionListWithType(page: Int, size: Int, long: Double, lat: Double, type: PromotionListTypeEnum) -> Promise<[PromotionStoreDTO]> {
        return apiManager.getShopperPromotionListWithType(page: page, size: size, long: long, lat: lat, type: type)
    }
    
    func getPromotionRedeemInfo(promotionId: Int64, branchId: Int64) -> Promise<PromotionRedeemInfoDTO> {
        return apiManager.getPromotionRedeemInfo(promotionId: promotionId, branchId: branchId)
    }
    
    func getBranchesInChain(promotionId: Int64, lat: Double, lng: Double) -> Promise<[BranchInfoDTO]> {
        return apiManager.getBranchesInChain(promotionId: promotionId, lat: lat, lng: lng)
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
    
    func getPromotionPaidHistoryDetail(_ id: Int64) -> Promise<PromotionPaidDTO> {
        return apiManager.getPromotionPaidHistoryDetail(id)
    }
    
    func getShopperPromotionSaved(page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        return apiManager.getShopperPromotionSaved(page: page, size: size, long: long, lat: lat)
    }
   
    func getShopperPromotionRunning(page: Int, size: Int, long: Double, lat: Double, storeId: Int64) -> Promise<JSON> {
        return apiManager.getShopperPromotionRunning(page: page, size: size, long: long, lat: lat, storeId: storeId)
    }
   
    func getShopperPromotionPurchased(page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        return apiManager.getShopperPromotionPurchased(page: page, size: size, long: long, lat: lat)
    }
   
    func getShopperPromotionHistory(page: Int, size: Int) -> Promise<[PromotionStoreDTO]> {
        return apiManager.getShopperPromotionHistory(page: page, size: size)
    }
   
    func getRetailerPromotionScannedList(page: Int, size: Int) -> Promise<[PromotionCodeInfoDTO]> {
        return apiManager.getRetailerPromotionScannedList(page: page, size: size)
    }
    
    func getRetailerCountPromotion() -> Promise<Int> {
        return apiManager.getRetailerCountPromotion()
    }
    
    func searchPromotionsWithText(_ text: String, page: Int, size: Int, long: Double, lat: Double) -> Promise<CollectionPromotionInfoDTO> {
        return apiManager.searchPromotionsWithText(text, page: page, size: size, long: long, lat: lat)
    }
    
    func getSuggestKeySearchForPromotion(lat: Double, lon: Double) -> Promise<[String]> {
        return apiManager.getSuggestKeySearchForPromotion(lat: lat, lon: lon)
    }
    
    func getShopperPromotionInStore(storeId: Int64, type: PromotionListTypeEnum, page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        return apiManager.getShopperPromotionInStore(storeId: storeId, type: type, page: page, size: size, long: long, lat: lat)
    }
    
    func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON> {
        return apiManager.getPromotionStoreGroup(page: page, size: size, long: long, lat: lat)
    }
}
