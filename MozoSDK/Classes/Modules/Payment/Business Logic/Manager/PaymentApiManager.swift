//
//  PaymentApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
import PromiseKit
import SwiftyJSON
let PAYMENT_REQUEST_API_PATH = ""
public extension ApiManager {
    /// Call API to get a list payment request from an address.
    ///
    /// - Parameters:
    ///   - address: the address
    ///   - page: the number of page data
    ///   - size: the number of payment request item
    public func getListPaymentRequest(address: String, page: Int = 0, size: Int = 15) -> Promise<[PaymentRequestDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_URL + PAYMENT_REQUEST_API_PATH + "txhistory/\(address)?page=\(page)&size=\(size)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list payment request, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)["array"]
                    let list = PaymentRequestDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get payment request: " + error.localizedDescription)
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
