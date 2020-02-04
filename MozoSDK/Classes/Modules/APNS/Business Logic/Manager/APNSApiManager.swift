//
//  APNSApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/31/20.
//

import Foundation
import PromiseKit
import SwiftyJSON

let APNS_USER_DEVICE_API_PATH = "/user-device"
public extension ApiManager {
    func sendRegisterFCMToken(registerDeviceInfo: APNSDeviceRegisterDTO) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + APNS_USER_DEVICE_API_PATH + "/register"
            let param = registerDeviceInfo.toJSON()
            print("Send device info to register APNS: \(JSON(param).rawString() ?? "NULL")")
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send device info to register APNS, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request send device info to register APNS: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
