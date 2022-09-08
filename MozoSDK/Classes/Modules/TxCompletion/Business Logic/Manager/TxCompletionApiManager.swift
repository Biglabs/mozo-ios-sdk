//
//  TxCompletionApiManager.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/7/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

public extension ApiManager {
    /// Call API to get transaction status from a transaction hash.
    ///
    /// - Parameters:
    ///   - hash: the transaction hash
    func getTxStatus(hash: String) -> Promise<TransactionStatusType> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + "/txs/\(hash)/status"
            self.execute(.get, url: url)
                .done { json -> Void in
                    if let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_STATUS_KEY].string {
                        if let status = TransactionStatusType(rawValue: jobj) {
                            seal.fulfill(status)
                        }
                    }
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
