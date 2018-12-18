//
//  AuthApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/14/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let AUTH_CHECK_TOKEN_API_PATH = "/protocol/openid-connect/userinfo"
public extension ApiManager {
    public func checkTokenExpired() -> Promise<[String : Any]> {
        return Promise { seal in
            let url = Configuration.AUTH_ISSSUER + AUTH_CHECK_TOKEN_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish check token expired, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error check token expired: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
