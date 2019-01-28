//
//  ImageServiceApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/27/19.
//

import Foundation
import PromiseKit
import SwiftyJSON

let IMAGE_SERVICE_API_PATH = "/image"
public extension ApiManager {
    public func getUrlToUploadImage() -> Promise<String> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + IMAGE_SERVICE_API_PATH + "/url-for-upload-url"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get url to upload image, json response: \(json)")
                    let jobj = JSON(json)
                    if let result = jobj[RESPONSE_TYPE_RESULT_KEY].string {
                        seal.fulfill(result)
                    }
                }
                .catch { error in
                    print("Error when request to get url to upload image: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func uploadImage(images: [UIImage], url: String) -> Promise<[String]> {
        return Promise { seal in
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for image in images {
                    if let imgData = UIImagePNGRepresentation(image) {
                        multipartFormData.append(imgData, withName: "\(Date().timeIntervalSince1970).png", mimeType: "image/png")
                    }
                }
            }, to: url, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("Finish request to upload image, response: \(response)")
                        guard let json = response.result.value as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        self.handleApiResponseJSON(json, url: url).done({ (jsonData) in
                            let jobj = JSON(jsonData)
                            let items = jobj.array ?? []
                            var values : [String] = []
                            for item in items {
                                if let string = item[RESPONSE_TYPE_VALUE_KEY].string {
                                    values.append(string)
                                }
                            }
                            seal.fulfill(values)
                        }).catch({ (error) in
                            seal.reject(error)
                        })
                    }
                case .failure(let error):
                    print("Error when request to upload image: " + error.localizedDescription)
                }
            })
        }
    }
}
