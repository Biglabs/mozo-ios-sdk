//
//  SalePersonDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/5/19.
//

import Foundation
import SwiftyJSON

public class SalePersonDTO : ResponseObjectSerializable {
    public var id: Int64?
    public var phoneNum: String?
    public var storeAdmin: Bool?
    public var storeInfoId: Int64?
    public var userUUID: String?
    
    public required init(phoneNum: String){
        self.phoneNum = phoneNum
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].int64
        self.phoneNum = json["phoneNum"].string
        self.storeAdmin = json["storeAdmin"].bool
        self.storeInfoId = json["storeInfoId"].int64
        self.userUUID = json["userUUID"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let id = self.id {
            json["id"] = id
        }
        if let phoneNum = self.phoneNum {json["phoneNum"] = phoneNum}
        if let storeAdmin = self.storeAdmin {json["storeAdmin"] = storeAdmin}
        if let storeInfoId = self.storeInfoId {json["storeInfoId"] = storeInfoId}
        if let userUUID = self.userUUID {json["userUUID"] = userUUID}
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [SalePersonDTO] {
        let array = json.array?.map({ SalePersonDTO(json: $0)! })
        return array ?? []
    }
}
