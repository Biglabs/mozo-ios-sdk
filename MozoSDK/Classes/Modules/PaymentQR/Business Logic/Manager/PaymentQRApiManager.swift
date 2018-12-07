//
//  PaymentQRApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
import PromiseKit
import SwiftyJSON
public extension ApiManager {
    /// Call API to send a payment request to an address.
    ///
    /// - Parameters:
    ///   - address: the address
    ///   - request: the payment request
    public func sendPaymentRequest(address: String, request: PaymentRequestDTO) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_URL + PAYMENT_REQUEST_API_PATH
            self.execute(.post, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send payment request, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request send payment request: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
