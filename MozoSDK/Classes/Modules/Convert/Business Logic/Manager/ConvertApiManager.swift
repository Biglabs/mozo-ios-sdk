//
//  ConvertApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension ApiManager {
    public func getGasPrices() -> Promise<GasPriceDTO> {
        return Promise { seal in
            let url = Configuration.BASE_URL + "/getGasPrices"
            self.execute(.get , url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get gas prices, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let gasPrice = GasPriceDTO.init(json: jobj) {
                        seal.fulfill(gasPrice)
                    } else {
                        
                    }
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request get gas prices: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func sendPrepareConvertTransaction(_ transaction: ConvertTransactionDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ONCHAIN_PATH + "/prepareConvertMozoXToSolo"
            let param = transaction.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send prepare convert transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let tx = IntermediaryTransactionDTO(json: jobj)
                    seal.fulfill(tx!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request send prepare convert transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func sendSignedConvertTransaction(_ transaction: IntermediaryTransactionDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ONCHAIN_PATH + "/sign-transfer"
            let param = transaction.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send signed convert transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let tx = IntermediaryTransactionDTO(json: jobj)
                    seal.fulfill(tx!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request send signed convert transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
