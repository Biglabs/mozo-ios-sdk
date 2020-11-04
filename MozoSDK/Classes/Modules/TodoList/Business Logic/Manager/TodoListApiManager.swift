//
//  TodoListApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/13/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension ApiManager {
    public func getShopperTodoList(blueToothOff: Bool, long: Double, lat: Double) -> Promise<[TodoDTO]> {
        return Promise { seal in
            let params = ["blueToothOff" : blueToothOff,
                          "lat": lat,
                          "lon": long] as [String : Any]
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/getTodoListShopper?\(params.queryString)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Shopper Todo List, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let array = TodoDTO.arrayFromJson(jobj)
                    seal.fulfill(array)
                }
                .catch { error in
                    print("Error when request get Shopper Todo List: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getTodoListSetting() -> Promise<TodoSettingDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_API_PATH + "/getTodoListSetting/v1"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get Todo List Setting, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let todo = TodoSettingDTO(json: jobj) {
                        seal.fulfill(todo)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get Todo List Setting: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
