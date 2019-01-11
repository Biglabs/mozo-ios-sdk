//
//  ShopperApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/7/19.
//

import Foundation
import PromiseKit
import SwiftyJSON

let SHOPPER_API_PATH = "/shopper"
let SHOPPER_AIRDROP_API_PATH = SHOPPER_API_PATH + "/airdrop"
let SHOPPER_FAVORITE_API_PATH = SHOPPER_API_PATH + "/favorite/stores"

public extension ApiManager {
    public func getAirdropStoresNearby(params: [String: Any]) -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            let query = "?\(params.queryString)"
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_API_PATH + "/nearby" + query
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get airdrop store nearby, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = StoreInfoDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get airdrop store nearby: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_API_PATH + "/color/range-settings"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get range color settings, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = AirdropColorRangeDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get range color settings: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getNearestStores() -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_API_PATH + "/nearest/stores"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get nearest stores, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = StoreInfoDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get nearest stores: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func searchStoresWithText(_ text: String, page: Int = 0, size: Int = 15) -> Promise<CollectionStoreInfoDTO> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "text" : text] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/search/stores" + "?\(params.queryString)"
            self.execute(.get, url: url, parameters: params)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to search stores, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let collection = CollectionStoreInfoDTO(json: jobj) {
                        seal.fulfill(collection)
                    }
                }
                .catch { error in
                    print("Error when request search stores: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    // MARK: Favorite
    public func getFavoriteStores() -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_FAVORITE_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get favorite stores, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = StoreInfoDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get favorite stores: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_FAVORITE_API_PATH
            let method = isMarkFavorite ? HTTPMethod.post : .delete
            self.execute(method, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to \(method.rawValue) favorite stores, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request \(method.rawValue) favorite stores: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
