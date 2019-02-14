//
//  RetailerApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/5/19.
//

import Foundation
import PromiseKit
import SwiftyJSON

let RETAILER_INFO_API_PATH = "/retailer/info"
let RETAILER_SALE_PERSON_API_PATH = "/retailer/saleperson"
let COMMON_COUNTRY_CODE_API_PATH = "/common/countries"
let TAGS_API_PATH = "/tags"
let RETAILER_STORE_INFO_API_PATH = "/retailer/storeInfo"
let RETAILER_STORE_INFO_HASHTAG_API_PATH = "/retailer/storeInfo/hashtag"
let RETAILER_STORE_INFO_PHOTO_API_PATH = "/retailer/storeInfo/photo"
public extension ApiManager {
    public func getRetailerInfo() -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_INFO_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get retailer info, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request get retailer info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func addSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_SALE_PERSON_API_PATH
            self.execute(.post, url: url, parameters: parameters)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to add retailer sale person, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request add retailer sale person: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getListSalePerson() -> Promise<[SalePersonDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_SALE_PERSON_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list sale person, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = SalePersonDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get list sale person: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func removeSalePerson(id: Int64) -> Promise<[String: Any]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_SALE_PERSON_API_PATH + "/\(id)"
            self.execute(.delete, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to remove retailer sale person, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request remove retailer sale person: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getListCountryCode() -> Promise<[CountryCodeDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + COMMON_COUNTRY_CODE_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list country code, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = CountryCodeDTO.arrayFromJson(jobj)
                    seal.fulfill(list)
                }
                .catch { error in
                    print("Error when request get list country code: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getCommonHashtag() -> Promise<[String]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + TAGS_API_PATH
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get list common hashtag, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let list = TagDTO.arrayFromJson(jobj)
                    let array = TagDTO.extractHashtagFromDTO(tagDTOs: list)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get list common hashtag: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateRetailerStoreInfo(storeInfo: StoreInfoDTO) -> Promise<StoreInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_STORE_INFO_API_PATH
            let param = storeInfo.rawData()
            print("Request to update store info, param: \(param)")
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update store info, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let storeInfo = StoreInfoDTO(json: jobj) {
                        seal.fulfill(storeInfo)
                    }
                }
                .catch { error in
                    print("Error when request update store info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateRetailerStoreInfoHashtag(hashTags: [String]) -> Promise<StoreInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_STORE_INFO_HASHTAG_API_PATH
            print("Request to update store info hashtag, param: \(hashTags)")
            self.execute(.put, url: url, parameters: hashTags)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update store info hashtag, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let storeInfo = StoreInfoDTO(json: jobj) {
                        seal.fulfill(storeInfo)
                    }
                }
                .catch { error in
                    print("Error when request update store info hashtag: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func updateRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_STORE_INFO_PHOTO_API_PATH
            let param = ["photos": photos]
            print("Request to update store info photo, param: \(param)")
            self.execute(.put, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to update store info photo, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let storeInfo = StoreInfoDTO(json: jobj) {
                        seal.fulfill(storeInfo)
                    }
                }
                .catch { error in
                    print("Error when request update store info photo: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func deleteRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + RETAILER_STORE_INFO_PHOTO_API_PATH
            let param = ["photos": photos]
            print("Request to delete store info photo, param: \(param)")
            self.execute(.delete, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to delete store info photo, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let storeInfo = StoreInfoDTO(json: jobj) {
                        seal.fulfill(storeInfo)
                    }
                }
                .catch { error in
                    print("Error when request delete store info photo: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
