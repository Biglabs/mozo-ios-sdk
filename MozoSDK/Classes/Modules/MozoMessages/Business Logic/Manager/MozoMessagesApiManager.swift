//
//  MozoMessagesApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/3/20.
//

import Foundation
import SwiftyJSON
import PromiseKit
extension ApiManager {
    public func getConversationList(page: Int, size: Int) -> Promise<[Conversation]> {
        return Promise { seal in
            let params = [
                "size" : size,
                "page" : page
                ] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/message/getListContactMessage?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    let jobj = SwiftyJSON.JSON(json)
                    let result = jobj[RESPONSE_TYPE_ARRAY_KEY].array?.map({ Conversation(json: $0)! }) ?? []
                    seal.fulfill(result)
                }
                .catch { error in
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getChatMessages(id: Int, page: Int, size: Int) -> Promise<[ConversationMessage]> {
        return Promise { seal in
            let params = [
                "id" : id,
                "size" : size,
                "page" : page
                ] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/message/getListMessageDetail?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    let jobj = SwiftyJSON.JSON(json)
                    let result = jobj[RESPONSE_TYPE_ARRAY_KEY].array?.map({ ConversationMessage(json: $0)! }) ?? []
                    seal.fulfill(result)
                }
                .catch { error in
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
