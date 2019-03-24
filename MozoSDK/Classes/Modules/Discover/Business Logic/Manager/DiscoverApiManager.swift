//
//  DiscoverApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/20/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
let DISCOVER_AIRDROP_EVENT_PATH = "/discover/airdrop"
extension ApiManager {
    public func getDiscoverAirdrops(type: AirdropEventDiscoverType, page: Int, size: Int, long: Double, lat: Double) -> Promise<[String: Any]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "userLat": lat,
                          "userLng": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + DISCOVER_AIRDROP_EVENT_PATH + "/\(type.rawValue)?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get discover \(type.rawValue) Airdrop Event list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let arrayObj = jobj[RESPONSE_TYPE_ARRAY_KEY]
                    let array = AirdropEventDiscoverDTO.arrayFromJson(arrayObj)
                    let totalNumber = jobj[RESPONSE_TYPE_TOTAL_KEY].intValue
                    let result : [String: Any] = [RESPONSE_TYPE_TOTAL_KEY: totalNumber, RESPONSE_TYPE_ARRAY_KEY: array]
                    seal.fulfill(result)
                }
                .catch { error in
                    print("Error when request get discover \(type.rawValue) Airdrop Event list: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
