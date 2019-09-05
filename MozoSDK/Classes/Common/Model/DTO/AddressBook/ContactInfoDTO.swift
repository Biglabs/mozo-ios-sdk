//
//  ContactInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/27/19.
//

import Foundation
import SwiftyJSON
public class ContactInfoDTO: ResponseObjectSerializable {
    
    public var name: String?
    public var phoneNums: [String]?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.name = json["name"].string
        self.phoneNums = json["phoneNums"].array?.map({ $0.string ?? "" })
    }
    
    public required init?(){}
    
    public required init(name: String, phoneNums: [String]){
        self.name = name
        self.phoneNums = phoneNums
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let name = self.name {
            json["name"] = name
        }
        if let phoneNums = self.phoneNums {
            json["phoneNums"] = phoneNums
        }
        return json
    }
}
