//
//  ResponseDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/12/18.
//

import Foundation
import SwiftyJSON
public let RESPONSE_TYPE_ARRAY_KEY = "items"
public let RESPONSE_TYPE_RESULT_KEY = "result"
public let RESPONSE_TYPE_VALUE_KEY = "value"
public class ResponseDTO: ResponseObjectSerializable {
    public var success: Bool
    public var error: String?
    public var data: [String: Any]
    
    public required init?(json: SwiftyJSON.JSON) {
        self.success = json["success"].boolValue
        self.error = json["error"].string
        self.data = json["data"].dictionaryValue
        if let array = json["data"].array {
            let result : [String: Any] = [RESPONSE_TYPE_ARRAY_KEY: array]
            self.data = result
        }
    }
    
    public required init?(){
        self.success = false
        self.data = [:]
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["success"] = success
        if let error = self.error {
            json["error"] = error
        }
        json["data"] = data
        
        return json
    }
}
