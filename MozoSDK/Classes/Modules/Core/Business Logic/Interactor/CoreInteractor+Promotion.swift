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
    
    func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
        return apiManager.updateFavoritePromotion(promotionId, isFavorite: isFavorite)
    }

    func getShopperPromotionRunning(page: Int, size: Int, long: Double, lat: Double, storeId: Int64) -> Promise<JSON> {
        return apiManager.getShopperPromotionRunning(page: page, size: size, long: long, lat: lat, storeId: storeId)
    }
   
    func getRetailerPromotionScannedList(page: Int, size: Int) -> Promise<[PromotionCodeInfoDTO]> {
        return apiManager.getRetailerPromotionScannedList(page: page, size: size)
    }
    
    func getRetailerCountPromotion() -> Promise<Int> {
        return apiManager.getRetailerCountPromotion()
    }
    
    func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON> {
        return apiManager.getPromotionStoreGroup(page: page, size: size, long: long, lat: lat)
    }
}
