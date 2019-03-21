//
//  WithdrawApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/20/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
public extension ApiManager {
    public func withdrawAirdropEvent(eventId: Int64) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/prepare-event/withDraw/\(eventId)"
            print("Withdraw airdrop event with id: \(eventId)")
            self.execute(.post, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to withdraw airdrop event with id [\(eventId)], json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let tx = IntermediaryTransactionDTO(json: jobj) {
                        seal.fulfill(tx)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request withdraw airdrop event with id [\(eventId)]: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func sendSignedWithdrawAirdropEventTx(_ transaction: IntermediaryTransactionDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/sign-withDraw"
            let param = transaction.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to sign withdraw airdrop event, json response: \(json)")
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
                    print("Error when request to sign withdraw airdrop event: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
