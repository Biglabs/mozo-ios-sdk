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
    public func getDiscoverNearestAirdrops(page: Int, size: Int, long: Double, lat: Double) -> Promise<[AirdropEventDiscoverDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + DISCOVER_AIRDROP_EVENT_PATH + "/nearest?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get discover nearest Airdrop Event list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = AirdropEventDiscoverDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get discover nearest Airdrop Event list: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getDiscoverTopAirdrops(page: Int, size: Int, long: Double, lat: Double) -> Promise<[AirdropEventDiscoverDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + DISCOVER_AIRDROP_EVENT_PATH + "/top?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get discover top Airdrop Event list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = AirdropEventDiscoverDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get discover top Airdrop Event list: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getDiscoverUpcomingAirdrops(page: Int, size: Int, long: Double, lat: Double) -> Promise<[AirdropEventDiscoverDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + DISCOVER_AIRDROP_EVENT_PATH + "/upcoming?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get discover upcoming Airdrop Event list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = AirdropEventDiscoverDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get discover upcoming Airdrop Event list: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
