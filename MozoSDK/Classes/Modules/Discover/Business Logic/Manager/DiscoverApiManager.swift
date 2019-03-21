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
    public func getDiscoverAirdrops(type: AirdropEventDiscoverType, page: Int, size: Int, long: Double, lat: Double) -> Promise<[AirdropEventDiscoverDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + DISCOVER_AIRDROP_EVENT_PATH + "/\(type.rawValue)?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get discover \(type.rawValue) Airdrop Event list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = AirdropEventDiscoverDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
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
