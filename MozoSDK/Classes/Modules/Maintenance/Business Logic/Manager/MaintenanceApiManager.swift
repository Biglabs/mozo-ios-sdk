//
//  MaintenanceApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

extension ApiManager {
    public static func checkMaintenence() -> Promise<MaintenanceStatusType> {
        return Promise { seal in
            let url = Configuration.BASE_HOST + "/system-status"
            AF.request(url, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        
                        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        let jsonObj = JSON(json)
                        if let mozoResponse = ResponseDTO(json: jsonObj),
                            mozoResponse.success,
                            let stringStatus = SwiftyJSON.JSON(mozoResponse.data)["status"].string,
                            let status = MaintenanceStatusType(rawValue: stringStatus) {
                            seal.fulfill(status)
                            return
                        }
                        seal.fulfill(.MAINTAINED)
                    case .failure(let error):
                        print("Check maintenance failed with error: \(error.localizedDescription), url: \(url))")
                        seal.reject(error)
                    }
            }
        }
    }
}
