//
//  PaymentRequestDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
import SwiftyJSON
public class PaymentRequestDTO: ResponseObjectSerializable {
    public var id: Int64?
    public var content: String?
    public var timeInSec: Int64?
    
    public required init(content: String){
        self.content = content
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].int64
        self.content = json["content"].string
        self.timeInSec = json["timeInSec"].int64
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let id = self.id {
            json["id"] = id
        }
        if let content = self.content {
            json["content"] = content
        }
        if let timeInSec = self.timeInSec {
            json["timeInSec"] = timeInSec
        }

        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [PaymentRequestDTO] {
        let array = json.array?.map({ PaymentRequestDTO(json: $0)! })
        return array ?? []
    }
}
