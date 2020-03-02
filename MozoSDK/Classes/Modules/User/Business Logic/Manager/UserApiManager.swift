//
//  WalletApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let USER_API_PATH = "/user-profile"
public extension ApiManager {
    func getUserProfile() -> Promise<UserProfileDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + USER_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get user profile, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    print("Error when request get user profile: " + error.localizedDescription)
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + USER_API_PATH + "/avatar-url"
            let param = userProfile.rawData()
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update avatar to user profile, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request update avatar to user profile: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return Promise { seal in
            let url = Configuration.BASE_URL + USER_API_PATH
            let param = userProfile.rawData()
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update user profile, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request update user profile: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
