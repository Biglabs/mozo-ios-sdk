//
//  WalletApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/8/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension ApiManager {
    public func updateWallets(walletInfo: WalletInfoDTO) -> Promise<UserProfileDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + USER_API_PATH + "/v1/walletAll"
            let param = walletInfo.rawData()
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update wallet info to user profile, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request update wallet info to user profile: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateOnlyOnchainWallet(onchainAddress: String) -> Promise<UserProfileDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + USER_API_PATH + "/updateWalletOnchain"
            let walletInfo = WalletInfoDTO(onchainAddress: onchainAddress)
            let param = walletInfo.rawData()
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update only onchain address in wallet info to user profile, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request update only onchain address in wallet info to user profile: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateWalletsForResettingPIN(walletInfo: WalletInfoDTO) -> Promise<UserProfileDTO> {
        return Promise { seal in
            // PUT /api/app/user-profile/saveWalletResetPin
            let url = Configuration.BASE_STORE_URL + USER_API_PATH + "/saveWalletResetPin"
            let param = walletInfo.rawData()
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update wallet info when resetting PIN to user profile, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request update wallet info when resetting PIN to user profile: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateWalletsForChangingPIN(walletInfo: WalletInfoDTO) -> Promise<UserProfileDTO> {
        return Promise { seal in
            // PUT /api/app/user-profile/saveWalletChangePin
            let url = Configuration.BASE_STORE_URL + USER_API_PATH + "/saveWalletChangePin"
            let param = walletInfo.rawData()
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update wallet info when changing PIN from auto to manual, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request update wallet info when changing PIN from auto to manual: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
