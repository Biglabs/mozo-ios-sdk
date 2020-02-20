//
//  BranchApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let RETAILER_BRANCH_API_PATH = "/retailer/branches"
extension ApiManager {
    func createNewBranch(_ branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_BRANCH_API_PATH
            let param = branchInfo.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to create new branch, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let result = BranchInfoDTO(json: jobj) {
                        seal.fulfill(result)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request to create new branch: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getBranchList(page: Int, size: Int) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_BRANCH_API_PATH
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
}
