//
//  TransactionApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/20/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let TX_API_PATH = "/solo/contract/solo-token/"
public extension ApiManager {
    func getTokenInfoFromAddress(_ address: String) -> Promise<TokenInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_URL + TX_API_PATH + "balance/\(address)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get token info, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let tokenInfo = TokenInfoDTO.init(json: jobj)
                    seal.fulfill(tokenInfo!)
                    self.delegate?.didLoadTokenInfoSuccess(tokenInfo!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request get token info: " + error.localizedDescription)
                    seal.reject(err)
                    self.delegate?.didLoadTokenInfoFailed()
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func transferTransaction(_ transaction: TransactionDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_URL + TX_API_PATH + "transfer"
            let param = transaction.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send transfer transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let tx = IntermediaryTransactionDTO(json: jobj)
                    seal.fulfill(tx!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request send transfer transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func sendSignedTransaction(_ transaction: IntermediaryTransactionDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_URL + TX_API_PATH + "send-signed-tx"
            let param = transaction.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send signed transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let tx = IntermediaryTransactionDTO(json: jobj)
                    seal.fulfill(tx!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request send signed transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
