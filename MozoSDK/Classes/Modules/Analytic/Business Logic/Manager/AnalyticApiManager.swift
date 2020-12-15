//
//  AnalyticApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/14/18.
//

import Foundation
import PromiseKit
import SwiftyJSON

let RETAILER_ANALYTICS_RESOURCE_API_PATH = "/retailer/analytics"
public extension ApiManager {
    func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_ANALYTICS_RESOURCE_API_PATH + "/home/v2"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get retailer analytic home, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let result = RetailerAnalyticsHomeDTO(json: jobj)
                    seal.fulfill(result)
                }
                .catch { error in
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_ANALYTICS_RESOURCE_API_PATH + "/customer-and-airdrop"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get retailer analytic list, json response: \(json)")
                    let array = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let result = RetailerCustomerAnalyticDTO.arrayFromJson(array)
                    seal.fulfill(result)
                }
                .catch { error in
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getRetailerAnalyticAmountAirdropList(page: Int = 0, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[AirDropReportDTO]> {
        return Promise { seal in
            var params = ["size" : size,
                          "page" : page] as [String : Any]
            if year > 0 {
                params["yearTime"] = year
            }
            if month > 0 {
                params["monthTime"] = month
            }
            let url = Configuration.BASE_STORE_URL + RETAILER_ANALYTICS_RESOURCE_API_PATH + "/amount-air-drop" + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get retailer analytic amount airdrop list, json response: \(json)")
                    let array = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let result = AirDropReportDTO.arrayFromJson(array)
                    seal.fulfill(result)
                }
                .catch { error in
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func getVisitCustomerList(page: Int = 0, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[VisitedCustomerDTO]> {
        return Promise { seal in
            var params = ["size" : size,
                          "page" : page] as [String : Any]
            if year > 0 {
                params["yearTime"] = year
            }
            if month > 0 {
                params["monthTime"] = month
            }
            let url = Configuration.BASE_STORE_URL + RETAILER_ANALYTICS_RESOURCE_API_PATH + "/visited-customers" + "?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get visit customers list, json response: \(json)")
                    let array = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let result = VisitedCustomerDTO.arrayFromJson(array)
                    seal.fulfill(result)
                }
                .catch { error in
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
