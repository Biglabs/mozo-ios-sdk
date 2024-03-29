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
let RETAILER_RESOURCE_API_PATH = "/retailer"
public extension ApiManager {
    
    func getRetailerPromotionList(page: Int, size: Int, statusRequest: PromotionStatusRequestEnum) -> Promise<[PromotionDTO]> {
        if statusRequest == .SCHEDULE {
            return Promise { seal in
                let params = ["size" : size,
                              "page" : page] as [String : Any]
                let url = Configuration.BASE_STORE_URL + RETAILER_RESOURCE_API_PATH + "/getListPromoScheduled?\(params.queryString)"
                self.execute(.get, url: url)
                    .done { json -> Void in
                        // JSON info
                        "Finish request to get Promotion list with type \(statusRequest), json response: \(json)".log()
                        let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                        let array = PromotionDTO.arrayFromJson(jobj)
                        seal.fulfill(array)
                    }
                    .catch { error in
                        "Error when request get Promotion list with type \(statusRequest): \(error.localizedDescription)".log()
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
            let url = Configuration.BASE_STORE_URL + RETAILER_RESOURCE_API_PATH + "/getListPromo?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    "Finish request to get Promotion list with type \(statusRequest), json response: \(json)".log()
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    "Error when request get Promotion list with type \(statusRequest): \(error.localizedDescription)".log()
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_RESOURCE_API_PATH + "/processPromoCode?code=\(code)"
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
    
    func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO> {
        return Promise { seal in
            var params = ["code" : code] as [String : Any]
            if let billInfo = billInfo {
                params["billId"] = billInfo
            }
            let url = Configuration.BASE_STORE_URL + RETAILER_RESOURCE_API_PATH + "/usePromoCode"
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
    
    func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_RESOURCE_API_PATH + "/cancelPromoCode?code=\(code)"
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
    
    func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
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
    
    func getRetailerPromotionScannedList(page: Int, size: Int) -> Promise<[PromotionCodeInfoDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page] as [String : Any]
            let url = Configuration.BASE_STORE_URL + RETAILER_RESOURCE_API_PATH + "/getListPromoScanned?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    "Finish request to get Scanned Promotion list, json response: \(json)".log()
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = PromotionCodeInfoDTO.arrayFrom(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    "Error when request get scanned Promotion list: \(error.localizedDescription)".log()
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getShopperPromotionRunning(page: Int, size: Int, long: Double, lat: Double, storeId: Int64) -> Promise<JSON> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long,
                          "branchId": storeId] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getListPromoRunningInBranch?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    "Finish request to get Shopper promotion running, json response: \(json)".log()
                    let jobj = SwiftyJSON.JSON(json)
                    seal.fulfill(jobj)
                }
                .catch { error in
                    "Error when request get Shopper promotion running: \(error.localizedDescription)".log()
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getRetailerCountPromotion() -> Promise<Int> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_RESOURCE_API_PATH + "/getCountPromotion"
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
    
    func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getListBranchNearByWithPromo?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion store group, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    seal.fulfill(jobj)
                }
                .catch { error in
                    print("Error when request get promotion store group: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
