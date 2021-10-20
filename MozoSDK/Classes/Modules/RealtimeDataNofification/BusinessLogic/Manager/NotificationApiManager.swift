//
//  NotificationApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/24/19.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

public extension ApiManager {
    func getListNotification(page: Int, size: Int) -> Promise<[WSMessage]> {
        return Promise { seal in
            let appTypeText = MozoSDK.appType.rawValue.uppercased()
            let params = ["size" : size,
                          "page" : page,
                          "appType" : appTypeText] as [String : Any]
            let url = Configuration.BASE_NOTIFICATION_URL + "/notify/client/getListNotify?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list notification, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = WSMessage.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get notification: " + error.localizedDescription)
                    //Handle error or give feedback to the user
                    guard let err = error as? ConnectionError else {
                        if error is AFError {
                            return seal.fulfill([])
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
