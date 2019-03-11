//
//  TxProcessApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension ApiManager {
    /// Call API to get transaction status from a transaction hash.
    ///
    /// - Parameters:
    ///   - hash: the transaction hash
    public func getOnchainTxStatus(hash: String) -> Promise<TransactionStatusType> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ONCHAIN_PATH + "/status/\(hash)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get onchain tx status, json response: \(json)")
                    if let jobj = SwiftyJSON.JSON(json)["status"].string {
                        if let status = TransactionStatusType(rawValue: jobj) {
                            seal.fulfill(status)
                        }
                    }
                }
                .catch { error in
                    print("Error when request get onchain tx status: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
