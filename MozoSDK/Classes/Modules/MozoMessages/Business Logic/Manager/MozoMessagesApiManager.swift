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
    
    public func getConversationDetails(id: Int64) -> Promise<Conversation?> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/message/getContactMessageDetail?id=\(id)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    let jobj = SwiftyJSON.JSON(json)
                    let result = Conversation.init(json: jobj)
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
    
    public func getChatMessages(id: Int64, page: Int, size: Int) -> Promise<[ConversationMessage]> {
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
    
    public func updateReadConversation(conversationId: Int64, lastMessageId: Int) -> Promise<Any> {
        return Promise { seal in
            let params = [
                "id" : conversationId,
                "lastDetailId" : lastMessageId
            ] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/message/ackListMessageDetails"
            self.execute(.put, url: url, parameters: params)
                .done { json -> Void in
                    let jobj = SwiftyJSON.JSON(json)
                    let result = jobj[RESPONSE_TYPE_RESULT_KEY]
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
