//
//  TopUpWithdrawApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
public extension ApiManager {
     /*
     POST /api/app/topUp/prepareTopUp/withDraw
     prepareTopUpWithDraw
     */
    func withdrawTopUp() -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/prepareTopUp/withDraw"
            self.execute(.post, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to withdraw topup, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let tx = IntermediaryTransactionDTO(json: jobj) {
                        seal.fulfill(tx)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request withdraw topup: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    /*
    POST /api/app/topUp/signTopUp/withDraw
    signTopUpWithDrawTransaction
     */
    func sendSignedWithdrawTopUpTx(_ transaction: IntermediaryTransactionDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/signTopUp/withDraw"
            let param = transaction.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to sign withdraw topup, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let tx = IntermediaryTransactionDTO(json: jobj) {
                        seal.fulfill(tx)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request to sign withdraw topup: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
