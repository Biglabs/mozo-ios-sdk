//
//  ABImportApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension ApiManager {
    public func importContacts(_ contactInfo: ImportContactInfoDTO) -> Promise<[String: Any]> {
        return Promise { seal in
            let param = contactInfo.toJSON()
            let url = Configuration.BASE_STORE_URL + ADR_BOOK_API_PATH + "/import-contact"
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to import contact, json response: \(json)")
                    seal.fulfill(json)
                }
                .catch { error in
                    print("Error when request get import contact: " + error.localizedDescription)
                    //Handle error or give feedback to the user
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func checkProcessImportContact() -> Promise<AddressBookImportProcessDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ADR_BOOK_API_PATH + "/import-process-checking"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get process import contacts status, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let dto = AddressBookImportProcessDTO(json: jobj) {
                        seal.fulfill(dto)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get process import contacts status: " + error.localizedDescription)
                    //Handle error or give feedback to the user
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getAddressBookByPhoneNo(_ phoneNo: String) -> Promise<AddressBookDTO?> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ADR_BOOK_API_PATH + "/findContact/\(phoneNo)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get address book from phone no \(phoneNo), json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let dto = AddressBookDTO(json: jobj)
                    seal.fulfill(dto)
                }
                .catch { error in
                    print("Error when request get address book from phone no \(phoneNo): " + error.localizedDescription)
                    //Handle error or give feedback to the user
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
