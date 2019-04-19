//
//  InviteApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/16/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
let INVITE_API_PATH = "/invite"
extension ApiManager {
    public func getInviteLink(locale: String, inviteAppType: AppType) -> Promise<InviteLinkDTO> {
        return Promise { seal in
            let appShopper = self.appType == .Shopper
            let inviteShopper = inviteAppType == .Shopper
            let params = ["locale" : locale, "appShopper": appShopper, "inviteShopper" : inviteShopper] as [String : Any]
            let url = Configuration.BASE_STORE_URL + INVITE_API_PATH + "/getInviteLink"
            self.execute(.post, url: url, parameters: params)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get invite link, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let result = InviteLinkDTO(json: jobj) {
                        seal.fulfill(result)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get invite link: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getListLanguageInfo() -> Promise<[InviteLanguageDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + INVITE_API_PATH + "/getListLanguageInfo"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list invite language info, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let arrayObj = jobj[RESPONSE_TYPE_ARRAY_KEY]
                    let array = InviteLanguageDTO.arrayFromJson(arrayObj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get invite language info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateCodeLinkInstallApp(codeString: String) -> Promise<InviteLinkDTO> {
        return Promise { seal in
            let appShopper = self.appType == .Shopper
            let params = ["codeLink" : codeString, "appShopper": appShopper] as [String : Any]
            let url = Configuration.BASE_URL + INVITE_API_PATH + "/updateCodeLinkInstallApp"
            self.execute(.post, url: url, parameters: params)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update code link install app, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let result = InviteLinkDTO(json: jobj) {
                        seal.fulfill(result)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get update code link install app: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
