//
//  TxHistoryApiManager.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/2/18.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

public extension ApiManager {
    /// Call API to get a list transaction histories from an address.
    ///
    /// - Parameters:
    ///   - address: the address
    ///   - page: the number of page data
    ///   - type: type of history
    func getListTxHistory(address: String, page: Int = 0, type: TransactionType = .All) -> Promise<[TxHistoryDTO]> {
        return Promise { seal in
//            let url = Configuration.BASE_STORE_URL + TX_API_PATH + "txhistory/\(address)?page=\(page)&size=\(size)"
            var api = URL(string: Configuration.BASE_STORE_URL + TX_API_PATH + "txhistory/\(address)")!
            api.appendQueryItem(name: "page", value: String(page))
            api.appendQueryItem(name: "size", value: String(Configuration.PAGING_SIZE))
            if type != .All {
                api.appendQueryItem(name: "isReceive", value: String(type == .Received))
            }
            
            self.execute(.get, url: api.absoluteString)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list tx history, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = TxHistoryDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get list tx history: " + error.localizedDescription)
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
