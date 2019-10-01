//
//  AirdropApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/12/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let SHOPPER_AIRDROP_REPORT_API_PATH = "/shopper-airdrop"
let RETAILER_AIRDROP_API_PATH = "/air-drops"
let RETAILER_AIRDROP_RESOURCE_API_PATH = "/retailer/airdrops"
public extension ApiManager {
    func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_REPORT_API_PATH + "/report-beacon/v2"
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
    
    func getTodayCollectedAmount(startTime: Int, endTime: Int) -> Promise<NSNumber> {
        return Promise { seal in
            let params = ["startTime" : startTime,
                          "endTime" : endTime] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_AIRDROP_REPORT_API_PATH + "/get-amount-coin-by-user?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get amount of collected coin from time \(startTime) to time \(endTime), json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_RESULT_KEY]
                    if let number = jobj.number {
                        seal.fulfill(number)
                    }
                }
                .catch { error in
                    print("Error when request get amount of collected coin from time \(startTime) to time \(endTime): " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func createAirdropEvent(event: AirdropEventDTO) -> Promise<[IntermediaryTransactionDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/prepare-event"
            let param = event.toJSON()
            print("Create airdrop event params: \(param)")
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to Create airdrop event, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
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
    
    func sendSignedAirdropEventTx(_ transactionArray: [IntermediaryTransactionDTO]) -> Promise<String?> {
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
    func getSmartContractStatus(address: String) -> Promise<TransactionStatusType> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_API_PATH + "/check/\(address)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Smart Contract Status, json response: \(json)")
                    if let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_STATUS_KEY].string {
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
    
    func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        return Promise { seal in
            _ = getAirdropEventList(page: 0, size: 1).done { array -> Void in
                print("Finish request to get Latest Airdrop Event, array count: \(array.count)")
                if array.count > 0 {
                    let event = array[0]
                    seal.fulfill(event)
                }
            }
        }
    }
    
    func getRunningAirdropEvents(page: Int, size: Int) -> Promise<[AirdropEventDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                          "page" : page,
                          "isInPeriod" : true,
                          "sort" : "createdOn,desc"] as [String : Any]
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_RESOURCE_API_PATH + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Running Airdrop Event list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = AirdropEventDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Running Airdrop Event list: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getAirdropEventList(page: Int, size: Int = 15) -> Promise<[AirdropEventDTO]> {
        return Promise { seal in
            let params = ["size" : size,
                           "page" : page,
                           "sort" : "createdOn,desc"] as [String : Any]
            let url = Configuration.BASE_STORE_URL + RETAILER_AIRDROP_RESOURCE_API_PATH + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Airdrop Event list, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = AirdropEventDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Airdrop Event list: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getCreateAirdropEventSettings() -> Promise<AirdropEventSettingDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + "/retailer/getCreateAirdropEventSettings"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Airdrop Event Setting, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let setting = AirdropEventSettingDTO(json: jobj) {
                        seal.fulfill(setting)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get Airdrop Event Setting: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
