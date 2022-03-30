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
}
