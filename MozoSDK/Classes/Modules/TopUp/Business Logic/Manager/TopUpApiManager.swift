//
//  TopUpApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
import PromiseKit
import SwiftyJSON

let TOP_UP_API_PATH = "/topUp"
public extension ApiManager {
    /*
     GET /api/app/topUp/checkTopUp/{smartContractAddress}
    checkTopUp
    */
    func getTopUpTxStatus(smartContractAddress: String) -> Promise<TransactionStatusType> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/checkTopUp/\(smartContractAddress)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get topup tx status, json response: \(json)")
                    if let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_STATUS_KEY].string {
                        if let status = TransactionStatusType(rawValue: jobj) {
                            seal.fulfill(status)
                        }
                    }
                }
                .catch { error in
                    print("Error when request get topup tx status: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    /*
    GET /api/app/topUp/getTopUpAddress
    getTopUpAddress
    */
    func getTopUpAddress() -> Promise<String> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/getTopUpAddress"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get topup address, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let address = jobj["address"].string ?? ""
                    seal.fulfill(address)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request get topup address: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    /*
    GET /api/app/topUp/getTopUpBalance
    getTopUpBalance
    */
    func getTopUpBalance() -> Promise<TokenInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/getTopUpBalance"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get topup balance, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let tokenInfo = TokenInfoDTO.init(json: jobj)
                    seal.fulfill(tokenInfo!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request get topup balance: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    /*
     GET /api/app/topUp/getTopUpTxhistory
     getTxHistoryByAddress
     */
    func getTopUpTxHistory(page: Int = 0, size: Int = 15) -> Promise<[TxHistoryDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/getTopUpTxhistory?page=\(page)&size=\(size)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list topup tx history, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = TxHistoryDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get list topup tx history: " + error.localizedDescription)
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
    /*
    POST /api/app/topUp/prepareTopUp
    prepareTopUp
    */
    func prepareTopUpTransaction(_ valueTransfer: NSNumber) -> Promise<[IntermediaryTransactionDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/prepareTopUp"
            let param = ["valueTransfer" : valueTransfer]
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to prepare topup transfer transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let txArray = IntermediaryTransactionDTO.arrayFromJson(jobj)
                    seal.fulfill(txArray)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request prepare topup transfer transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    /*
    POST /api/app/topUp/signTopUp
    signTopUp
    */
    func sendTopUpSignedTransaction(_ transactionArray: [IntermediaryTransactionDTO]) -> Promise<String?> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TOP_UP_API_PATH + "/signTopUp"
            let param = IntermediaryTransactionDTO.arrayToJsonString(transactionArray)
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send signed topup transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let smartContractAddress = jobj["message"].stringValue
                    seal.fulfill(smartContractAddress)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request send signed topup transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
