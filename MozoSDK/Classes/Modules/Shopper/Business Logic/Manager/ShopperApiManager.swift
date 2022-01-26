//
//  ShopperApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/7/19.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

let SHOPPER_API_PATH = "/shopper"
let SHOPPER_AIRDROP_API_PATH = SHOPPER_API_PATH + "/airdrop"

let SHOPPER_SEARCH_API_PATH = SHOPPER_API_PATH + "/search/branches"
let SHOPPER_NEAREST_API_PATH = SHOPPER_API_PATH + "/nearest/stores"
let SHOPPER_RECOMMENDATION_API_PATH = SHOPPER_API_PATH + "/recommendation/branches"

public extension ApiManager {
    
    func getGPSBeacons(params: [String: Any]) -> Promise<[String]> {
        return Promise { seal in
            let query = "?\(params.queryString)"
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/beacon/gps" + query
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    "Finish request to get GPS beacons, json response: \(json)".log()
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = (jobj.array ?? []).filter({ $0.string != nil }).map({ $0.string! })
                    seal.fulfill(list)
                }
                .catch { error in
                    "Error when request get GPS beacons: \(error.localizedDescription)".log()
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getRecommendationStores(_ storeId: Int64, size: Int, long: Double?, lat: Double?) -> Promise<[BranchInfoDTO]> {
        return Promise { seal in
            var params = ["branchId" : storeId,
                          "top": size] as [String : Any]
            if let lat = lat, let long = long {
                params = ["branchId" : storeId,
                          "top": size,
                          "lat": lat,
                          "lon": long] as [String : Any]
            }
            let url = Configuration.BASE_STORE_URL + SHOPPER_RECOMMENDATION_API_PATH + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get recommendation stores, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = BranchInfoDTO.branchArrayFromJson(jobj)
                    seal.fulfill(list)
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
