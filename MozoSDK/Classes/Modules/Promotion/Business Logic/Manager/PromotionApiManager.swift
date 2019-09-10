//
//  PromotionApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/3/19.
//

import Foundation
import PromiseKit
import SwiftyJSON

let SHOPPER_PROMOTION_RESOURCE_API_PATH = "/shopperPromo"
let RETAILER_PROMOTION_RESOURCE_API_PATH = "/retailer"
public extension ApiManager {
    public func getPromoCreateSetting() -> Promise<PromotionSettingDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/getPromoCreateSetting"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion create setting, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let setting = PromotionSettingDTO(json: jobj) {
                        seal.fulfill(setting)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get promotion create setting: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func createPromotion(_ promotion: PromotionDTO) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/createPromo"
            let param = promotion.toJSON()
            print("Create promotion params: \(param)")
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to Create promotion, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request Create promotion: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getRetailerPromotionList(page: Int, size: Int, statusRequest: PromotionStatusRequestEnum) -> Promise<[PromotionDTO]> {
        if statusRequest == .SCHEDULE {
            return Promise { seal in
                let params = ["size" : size,
                              "page" : page] as [String : Any]
                let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/getListPromoScheduled?\(params.queryString)"
                self.execute(.get, url: url)
                    .done { json -> Void in
                        // JSON info
                        print("Finish request to get Promotion list with type \(statusRequest), json response: \(json)")
                        let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                        let array = PromotionDTO.arrayFromJson(jobj)
                        seal.fulfill(array)
                    }
                    .catch { error in
                        print("Error when request get Promotion list with type \(statusRequest): " + error.localizedDescription)
                        seal.reject(error)
                    }
                    .finally {
                        //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "statusRequest" : statusRequest.rawValue] as [String : Any]
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/getListPromo?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Promotion list with type \(statusRequest), json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Promotion list with type \(statusRequest): " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/processPromoCode?code=\(code)"
            self.execute(.put, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion code info, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let codeInfo = PromotionCodeInfoDTO(json: jobj) {
                        seal.fulfill(codeInfo)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get promotion code info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO> {
        return Promise { seal in
            var params = ["code" : code] as [String : Any]
            if let billInfo = billInfo {
                params["billId"] = billInfo
            }
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/usePromoCode"
            self.execute(.put, url: url, parameters: params)
            .done { json -> Void in
                // JSON info
                print("Finish request to use promotion code, json response: \(json)")
                let jobj = SwiftyJSON.JSON(json)
                if let codeInfo = PromotionCodeInfoDTO(json: jobj) {
                    seal.fulfill(codeInfo)
                } else {
                    seal.reject(ConnectionError.systemError)
                }
            }
            .catch { error in
                print("Error when request use promotion code: " + error.localizedDescription)
                seal.reject(error)
            }
            .finally {
            //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/cancelPromoCode?code=\(code)"
            self.execute(.put, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to cancel promotion code, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request cancel promotion code: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getShopperPromotionListWithType(page: Int, size: Int, long: Double, lat: Double, type: PromotionListTypeEnum) -> Promise<[PromotionStoreDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long,
                          "type" : type.rawValue] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getListPromo?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Shopper promotion list with type \(type.rawValue), json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionStoreDTO.arrayFrom(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Shopper promotion list with type \(type.rawValue): " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let params = ["promoId" : promotionId,
                          "saved" : isFavorite] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/updateSavedPromo"
            self.execute(.put, url: url, parameters: params)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to set favorite promotion, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request set favorite promotion: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getRetailerPromotionScannedList(page: Int, size: Int) -> Promise<[PromotionCodeInfoDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page] as [String : Any]
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/getListPromoScanned?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Scanned Promotion list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionCodeInfoDTO.arrayFrom(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get scanned Promotion list: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getShopperPromotionHistory(page: Int, size: Int) -> Promise<[PromotionStoreDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getListPromoHistoryInBag?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Shopper promotion history, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionStoreDTO.arrayFrom(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Shopper promotion history: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getShopperPromotionPurchased(page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getListPromoPurchasedInBag?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Shopper promotion purchased, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionStoreDTO.arrayFrom(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Shopper promotion purchased: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getShopperPromotionRunning(page: Int, size: Int, long: Double, lat: Double, storeId: Int64) -> Promise<JSON> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long,
                          "storeId": storeId] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getListPromoRunningInStore?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Shopper promotion running, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    seal.fulfill(jobj)
                }
                .catch { error in
                    print("Error when request get Shopper promotion running: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getShopperPromotionSaved(page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getListPromoSavedInBag?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Shopper promotion saved, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionStoreDTO.arrayFrom(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Shopper promotion saved: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getRetailerCountPromotion() -> Promise<Int> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/getCountPromotion"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Retailer count promotion, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_TOTAL_KEY]
                    let count = jobj.intValue
                    seal.fulfill(count)
                }
                .catch { error in
                    print("Error when request get Retailer count promotion: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func searchPromotionsWithText(_ text: String, page: Int = 0, size: Int = 15, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lon" : long,
                          "lat" : lat,
                          "text" : text] as [String : Any]
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/searchPromo?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to search promotions, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionStoreDTO.arrayFrom(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request search promotions: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getSuggestKeySearchForPromotion(lat: Double, lon: Double) -> Promise<[String]> {
        return Promise { seal in
            let params = ["lat" : lat,
                          "lon" : lon] as [String : Any]
            let url = Configuration.BASE_STORE_URL + RETAILER_PROMOTION_RESOURCE_API_PATH + "/getSuggestPromoHashtags" + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get suggestion search for promotion, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let result = jobj.arrayObject as? [String]
                    if let result = result {
                        seal.fulfill(result)
                    }
                }
                .catch { error in
                    print("Error when request get suggestion search for promotion: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
