//
//  AirdropApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/12/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let SHOPPER_AIRDROP_API_PATH = "/shopper/airdrop"
let SHOPPER_AIRDROP_REPORT_API_PATH = "/shopper-airdrop/report-beacon"
let RETAILER_AIRDROP_API_PATH = "/air-drops"
public extension ApiManager {
    public func getAirdropStoresNearby(params: [String: Any]) -> Promise<[StoreInfoDTO]> {
        return Promise { seal in
            let query = "?\(params.queryString)"
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_API_PATH + "/nearby" + query
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get airdrop store nearby, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)["array"]
                    let list = StoreInfoDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get airdrop store nearby: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_REPORT_API_PATH
            let data = ReportBeaconDTO(beaconInfoDTOList: beacons, status: status)
            let param = data.toJSON()
            print("Report ranged beacons params: \(data.rawString() ?? "NULL")")
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send Ranged Beacons, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request send Ranged Beacons: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_API_PATH + "/color/range-settings"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get range color settings, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)["array"]
                    let list = AirdropColorRangeDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get range color settings: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
        }
    }
    
    public func createAirdropEvent(event: AirdropEventDTO) -> Promise<[IntermediaryTransactionDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/prepare-event"
            let param = event.toJSON()
            print("Create airdrop event params: \(param)")
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to Create airdrop event, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)["array"]
                    let txArray = IntermediaryTransactionDTO.arrayFromJson(jobj)
                    seal.fulfill(txArray)
                }
                .catch { error in
                    print("Error when request Create airdrop event: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func sendSignedAirdropEventTx(_ transactionArray: [IntermediaryTransactionDTO]) -> Promise<String?> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/sign"
            let param = IntermediaryTransactionDTO.arrayToJsonString(transactionArray)
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print(json)
                    let jobj = SwiftyJSON.JSON(json)
                    let smartContractAddress = jobj["message"].stringValue
                    seal.fulfill(smartContractAddress)
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
    
    /// Call API to get status of a smart contract belong to airdrop event.
    ///
    /// - Parameters:
    ///   - address: the smart contract address
    public func getSmartContractStatus(address: String) -> Promise<TransactionStatusType> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/check/\(address)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Smart Contract Status, json response: \(json)")
                    if let jobj = SwiftyJSON.JSON(json)["status"].string {
                        if let status = TransactionStatusType(rawValue: jobj) {
                            seal.fulfill(status)
                        }
                    }
                }
                .catch { error in
                    print("Error when request get tx status: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
