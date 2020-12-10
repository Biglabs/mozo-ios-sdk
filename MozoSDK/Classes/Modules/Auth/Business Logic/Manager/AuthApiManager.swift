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
extension ApiManager {
    func checkTokenExpired() -> Promise<[String : Any]> {
        return Promise { seal in
            let url = Configuration.AUTH_ISSSUER + AUTH_CHECK_TOKEN_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    seal.fulfill(json)
                }
                .catch { error in
                    seal.reject(error)
                }
        }
    }
    
    func reportToken(_ token: String) -> Promise<Any> {
        return Promise { seal in
            "Report token \(token)".log()
            let url = Configuration.BASE_HOST + "/store/api/public/tokenHistory/addTokenHistory"
            let params = ["token" : token] as [String : Any]
            self.execute(.post, url: url, parameters: params)
                .done { json -> Void in
                    "Report token isSuccessful: \(json)".log()
                    seal.fulfill(json)
                }
                .catch { error in
                    "Report token failed: \(error)".log()
                    seal.reject(error)
                }
        }
    }
}
