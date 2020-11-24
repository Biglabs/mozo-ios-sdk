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
            let url = "\(Configuration.BASE_STORE_URL)/retailer/v1/branches"
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
    
    func updateBranchInfo(_ branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO> {
        return Promise { seal in
            let url = "\(Configuration.BASE_STORE_URL)/retailer/v1/branches/\(branchInfo.id ?? 0)"
            let param = branchInfo.toJSON()
            print("Request to update branch, param: \(param)")
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update branch, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let result = BranchInfoDTO(json: jobj) {
                        seal.fulfill(result)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request to update branch: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getBranchList(page: Int, size: Int, forSwitching: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + (forSwitching ? "/retailer/branchesForSwitching" : RETAILER_BRANCH_API_PATH)
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
   
   func deleteBranchInfoPhotos(_ branchId: Int64, photos: [String]) -> Promise<BranchInfoDTO> {
       return Promise { seal in
           let url = Configuration.BASE_STORE_URL + RETAILER_BRANCH_API_PATH + "/photo/\(branchId)"
           print("Request to delete branch info photo, param: \(photos)")
           self.execute(.delete, url: url, parameters: photos)
               .done { json -> Void in
                   // JSON info
                   print("Finish request to delete branch info photo, json response: \(json)")
                   let jobj = SwiftyJSON.JSON(json)
                   if let info = BranchInfoDTO(json: jobj) {
                       seal.fulfill(info)
                   }
               }
               .catch { error in
                   print("Error when request delete branch info photo: " + error.localizedDescription)
                   seal.reject(error)
               }
               .finally {
                   //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
           }
       }
   }
   
   func getBranchById(_ branchId: Int64) -> Promise<BranchInfoDTO> {
       return Promise { seal in
           let url = Configuration.BASE_STORE_URL + RETAILER_BRANCH_API_PATH + "/\(branchId)"
           self.execute(.get, url: url)
               .done { json -> Void in
                   // JSON info
                   print("Finish request to get branch with id \(branchId), json response: \(json)")
                   let jobj = SwiftyJSON.JSON(json)
                   if let info = BranchInfoDTO(json: jobj) {
                       seal.fulfill(info)
                   }
               }
               .catch { error in
                   print("Error when request get branch with id \(branchId): " + error.localizedDescription)
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
