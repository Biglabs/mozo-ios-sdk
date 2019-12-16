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
let SHOPPER_FAVORITE_API_PATH = "/favorite/stores"
let SHOPPER_SEARCH_API_PATH = SHOPPER_API_PATH + "/v1/search/stores"
let SHOPPER_NEAREST_API_PATH = SHOPPER_API_PATH + "/nearest/stores"
let SHOPPER_RECOMMENDATION_API_PATH = SHOPPER_API_PATH + "/recommendation/stores"

public extension ApiManager {
    func getAirdropStoresNearby(params: [String: Any]) -> Promise<[AirdropEventDiscoverDTO]> {
        return Promise { seal in
            let query = "?\(params.queryString)"
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/v1/airdrop/nearby" + query
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get airdrop store nearby, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = AirdropEventDiscoverDTO.arrayFromJson(jobj)
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
    
    func getGPSBeacons(userLat: Double, userLong: Double) -> Promise<[String]> {
        return Promise { seal in
            let params = ["userLat" : userLat,
                          "userLong": userLong] as [String : Any]
            let query = "?\(params.queryString)"
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/beacon/gps" + query
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get GPS beacons, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = (jobj.array ?? []).filter({ $0.string != nil }).map({ $0.string! })
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get GPS beacons: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]> {
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
    
    func getNearestStores(_ storeId: Int64) -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            let params = ["storeId" : storeId] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_NEAREST_API_PATH + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get nearest stores, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let collection = CollectionStoreInfoDTO(json: jobj) {
                        seal.fulfill(collection.stores ?? [])
                    }
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
    
    func getRecommendationStores(_ storeId: Int64, size: Int, long: Double?, lat: Double?) -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            var params = ["storeId" : storeId,
                          "top": size] as [String : Any]
            if let lat = lat, let long = long {
                params = ["storeId" : storeId,
                          "top": size,
                          "lat": lat,
                          "lon": long] as [String : Any]
            }
            let url = Configuration.BASE_STORE_URL + SHOPPER_RECOMMENDATION_API_PATH + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get recommendation stores, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let collection = CollectionStoreInfoDTO(json: jobj) {
                        seal.fulfill(collection.stores ?? [])
                    }
                }
                .catch { error in
                    print("Error when request get recommendation stores: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getListEventAirdropOfStore(_ storeId: Int64) -> Promise<[AirdropEventDiscoverDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/v1/store/\(storeId)/air-drops"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get event of store \(storeId), json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = AirdropEventDiscoverDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get event of store \(storeId): " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func searchStoresWithText(_ text: String, page: Int = 0, size: Int = 15, long: Double, lat: Double, sort: String = "distance") -> Promise<CollectionStoreInfoDTO> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lon" : long,
                          "lat" : lat,
                          "sort" : sort,
                          "text" : text] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_SEARCH_API_PATH + "?\(params.queryString)"
            self.execute(.get, url: url)
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
    func getFavoriteStores(page: Int, size: Int) -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/v1" + SHOPPER_FAVORITE_API_PATH + "?\(params.queryString)"
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
    
    func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + SHOPPER_FAVORITE_API_PATH + "/\(storeId)"
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
    
    func getStoreDetail(_ storeId: Int64) -> Promise<StoreInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/store/\(storeId)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get store detail with id \(storeId), json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let storeInfo = StoreInfoDTO(json: jobj) {
                        seal.fulfill(storeInfo)
                    }
                }
                .catch { error in
                    print("Error when request get store detail with id \(storeId): " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getSuggestKeySearch(lat: Double, lon: Double) -> Promise<[String]> {
        return Promise { seal in
            let params = ["lat" : lat,
                          "lon" : lon] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/suggestKeySearch" + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get suggestion search, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let result = jobj.arrayObject as? [String]
                    if let result = result {
                        seal.fulfill(result)
                    }
                }
                .catch { error in
                    print("Error when request get suggestion search: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
