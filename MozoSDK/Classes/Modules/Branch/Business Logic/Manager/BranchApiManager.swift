//
//  BranchApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/18.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

let RETAILER_BRANCH_API_PATH = "/retailer/branches"
extension ApiManager {
    
    func getBranchList(page: Int, forSwitching: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let params = [
                "page" : page,
                "size" : Configuration.PAGING_SIZE
            ] as [String : Any]
            let url = Configuration.BASE_STORE_URL + (forSwitching ? "/retailer/branchesForSwitching" : RETAILER_BRANCH_API_PATH) + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list branch, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request get list branch: " + error.localizedDescription)
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
    
    func switchBranch(_ branchId: Int64) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_BRANCH_API_PATH + "/switch/\(branchId)"
            self.execute(.put, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to switch branch, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request switch branch: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
       }
   }
    
    func checkBranchName(_ name: String) -> Promise<Any> {
        return Promise { seal in
            let url = "\(Configuration.BASE_STORE_URL)/retailer/branches/checkAvailableName"
            var json = Dictionary<String, Any>()
            json["name"] = name
            
            self.execute(.post, url: url, parameters: json)
                .done { json -> Void in
                    seal.fulfill(json)
                }
                .catch { error in
                    seal.reject(error)
                }
        }
    }
}
