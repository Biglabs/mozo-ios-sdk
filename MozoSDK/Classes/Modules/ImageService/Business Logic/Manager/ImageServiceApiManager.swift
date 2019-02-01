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
            let url = Configuration.BASE_STORE_URL + IMAGE_SERVICE_API_PATH + "/url-for-binary"
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
                    if let imgData = UIImageJPEGRepresentation(image, 1.0) {
                        let imageSize = imgData.count
                        print("Upload image with size in KB: \(Double(imageSize) / 1024.0)")
                        multipartFormData.append(imgData, withName: "", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/*")
                    }
                }
            }, to: url, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        print("Progress upload image with url \(url), \(progress.fractionCompleted * 100)%")
                    }
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let json):
                            print("Finish request to upload image, json: \(json)")
                            guard let json = json as? [String: Any] else {
                                return seal.reject(ConnectionError.systemError)
                            }
                            self.handleApiResponseJSON(json, url: url).done({ (jsonData) in
                                let jobj = JSON(jsonData)
                                let items = jobj[RESPONSE_TYPE_ARRAY_KEY].array ?? []
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
                        case .failure(let error):
                            print("Request failed with error: \(error.localizedDescription), url: \(url), detail: \(self.getErrorDetailMessage(responseData: response.data))")
                            let connectionError = self.checkResponse(response: response, error: error)
                            seal.reject(connectionError)
                        }
                    }
                case .failure(let error):
                    print("Error when request to upload image: " + error.localizedDescription)
                }
            })
        }
    }
}
