//
//  AirdropApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/12/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let SHOPPER_AIRDROP_API_PATH = "/api/shopper/airdrop"
let SHOPPER_AIRDROP_REPORT_API_PATH = "/api/shopper-airdrop/report-beacon"
public extension ApiManager {
    public func getAirdropStoresNearby(params: [String: Any]) -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            let query = "?\(params.queryString)"
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_API_PATH + "/nearby" + query
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get airdrop store nearby, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)["array"]
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
    
    public func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_REPORT_API_PATH
            let data = ReportBeaconDTO(beaconInfoDTOList: beacons, status: status)
            let param = data.toJSON()
            print("Report ranged beacons params: \(data.rawString() ?? "NULL")")
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send Ranged Beacons, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request send Ranged Beacons: " + error.localizedDescription)
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
                    let jobj = SwiftyJSON.JSON(json)["array"]
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
}
