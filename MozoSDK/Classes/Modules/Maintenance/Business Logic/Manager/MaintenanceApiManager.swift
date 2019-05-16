//
//  MaintenanceApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
import PromiseKit
import SwiftyJSON

extension ApiManager {
    public static func checkMaintenence() -> Promise<MaintenanceStatusType> {
        return Promise { seal in
            let url = Configuration.BASE_HOST + "/system-status"
            Alamofire.request(url, method: .get)
                .validate()
                .responseJSON { response in
                    print("Response from check maintenance: \(response)")
                    switch response.result {
                    case .success(let json):
                        print("Finish check maintenance with json: \(json)")
                        guard let json = json as? [String: Any] else {
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
                        print("Request check maintenance failed with error: \(error.localizedDescription), url: \(url))")
                        seal.reject(error)
                    }
            }
        }
    }
}
