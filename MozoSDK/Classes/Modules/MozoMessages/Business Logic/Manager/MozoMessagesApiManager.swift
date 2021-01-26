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
    public func getConversationList(text: String?, page: Int) -> Promise<[Conversation]> {
        return Promise { seal in
            var params = [
                "size" : Configuration.PAGING_SIZE,
                "page" : page
                ] as [String : Any]
            if let keyword = text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), keyword.count > 0 {
                params["text"] = keyword
            }
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
    
    public func getChatMessages(id: Int64, page: Int) -> Promise<[ConversationMessage]> {
        return Promise { seal in
            let params = [
                "id" : id,
                "size" : Configuration.PAGING_SIZE,
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
    
    
    public func responseConversation(conversationId: Int64, status: String) -> Promise<Any> {
        return Promise { seal in
            let params = [
                "id" : conversationId,
                "status" : status
            ] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/message/updateContactMessageStatus"
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
    
    public func updateReadConversation(conversationId: Int64, lastMessageId: Int64) -> Promise<Any> {
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
    
    public func sendMessage(id: Int64, message: String?, images: [String]?, userSend: Bool) -> Promise<Any> {
        return Promise { seal in
            //let params = ConversationMessage(id: id, message: message, images: images, timeCreatedOn: nil, timeRead: nil, userSend: userSend)
            var params = [
                "id" : id,
                "userSend" : userSend
            ] as [String: Any]
            if let msg = message, msg.count > 0 {
                params["message"] = msg
            }
            if let imgs = images, imgs.count > 0 {
                params["images"] = imgs
            }
            
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/message/sendMessage"
            self.execute(.post, url: url, parameters: params)
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
