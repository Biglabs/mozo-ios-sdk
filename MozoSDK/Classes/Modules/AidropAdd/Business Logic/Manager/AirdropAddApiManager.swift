//
//  AirdropAddApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/12/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

public extension ApiManager {
    public func sendAddMoreSignedAirdropEventTx(_ transaction: IntermediaryTransactionDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/sign-transfer"
            let param = transaction.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print(json)
                    let jobj = SwiftyJSON.JSON(json)
                    let tx = IntermediaryTransactionDTO(json: jobj)
                    seal.fulfill(tx!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print(err.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
