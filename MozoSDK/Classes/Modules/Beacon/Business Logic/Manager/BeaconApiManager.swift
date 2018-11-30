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
let RETAILER_INFO_API_PATH = "/retailer/info"
let RETAILER_SALE_PERSON_API_PATH = "/retailer/saleperson"
public extension ApiManager {
    public func registerBeacon(parameters: Any?, isCreateNew: Bool) -> Promise<[String: Any]> {
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

    public func getRetailerInfo() -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_INFO_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get retailer info, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request get retailer info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func addSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_SALE_PERSON_API_PATH
            self.execute(.post, url: url, parameters: parameters)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to add retailer sale person, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request add retailer sale person: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getListBeacons() -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_BEACON_API_PATH
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
}
