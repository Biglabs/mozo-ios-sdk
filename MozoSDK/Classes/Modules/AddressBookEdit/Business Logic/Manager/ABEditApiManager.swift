//
//  ABEditApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/23/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

public extension ApiManager {
    func deleteAddressBook(_ id: Int64) -> Promise<[String : Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ADR_BOOK_API_PATH + "/\(id)"
            self.execute(.delete, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to delete address book, json response: \(json)")
                    seal.fulfill(json)
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
