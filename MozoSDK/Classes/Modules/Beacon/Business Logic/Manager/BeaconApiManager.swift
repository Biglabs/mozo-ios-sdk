//
//  BeaconApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let RETAILER_BEACON_API_PATH = "/retailer/beacon"
extension ApiManager {
    func registerBeacon(parameters: Any?, isCreateNew: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_BEACON_API_PATH
            let method : HTTPMethod = isCreateNew ? .post : .put
            self.execute(method, url: url, parameters: parameters)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to \(method) beacon, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request \(method) beacon: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func deleteBeacon(beaconId: Int64) -> Promise<Bool> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_BEACON_API_PATH + "/\(beaconId)"
            self.execute(.delete, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to delete beacon, json response: \(json)")
                    seal.fulfill(true)
                }
                .catch { error in
                    print("Error when request delete beacon: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getListBeacons() -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + "/retailer/beaconByBranch"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list beacons, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request get list beacons: " + error.localizedDescription)
                    //Handle error or give feedback to the user
                    guard let err = error as? ConnectionError else {
                        if error is AFError {
                            return seal.fulfill([:])
                        }
                        return seal.reject(error)
                    }
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getBeacon(_ beaconId: Int64) -> Promise<BeaconInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_BEACON_API_PATH + "/\(beaconId)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get beacon by id [\(beaconId)], json response: \(json)")
                    let jobj = JSON(json)
                    if let beaconInfo = BeaconInfoDTO(json: jobj) {
                        seal.fulfill(beaconInfo)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get beacon by id [\(beaconId)]: " + error.localizedDescription)
                    //Handle error or give feedback to the user
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
