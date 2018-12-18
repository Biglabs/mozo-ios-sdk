//
//  ResponseDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/12/18.
//

import Foundation
import SwiftyJSON
public class ResponseDTO: ResponseObjectSerializable {
    public var error: Int?
    public var data: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.error = json["error"].int
        self.data = json["data"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let error = self.error {
            json["error"] = error
        }
        if let data = self.data {
            json["data"] = data
        }
        
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [PaymentRequestDTO] {
        let array = json.array?.map({ PaymentRequestDTO(json: $0)! })
        return array ?? []
    }
}
