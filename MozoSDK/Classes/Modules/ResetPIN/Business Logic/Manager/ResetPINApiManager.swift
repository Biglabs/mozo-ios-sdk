//
//  ResetPINApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/10/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension ApiManager {
    public func resetPINOfUserWallet(walletInfo: WalletInfoDTO) -> Promise<UserProfileDTO> {
        return Promise { seal in
            let url = Configuration.BASE_URL + USER_API_PATH + "/wallet/reset-pin"
            let param = walletInfo.rawData()
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to reset PIN of user wallet, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let userProfile = UserProfileDTO.init(json: jobj)
                    seal.fulfill(userProfile!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request to reset PIN of user wallet: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
