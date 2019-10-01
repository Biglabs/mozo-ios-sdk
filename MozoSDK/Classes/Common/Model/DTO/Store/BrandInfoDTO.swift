//
//  BrandInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/6/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import SwiftyJSON

public class BrandInfoDTO : ResponseObjectSerializable {
    public var address: String?
    public var id: Int64?
    public var imageLogo: String?
    public var latitude: NSNumber?
    public var longitude: NSNumber?
    public var name: String?
    public var phoneNum: String?
    
    public required init(id: Int64){
        self.id = id
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.address = json["address"].string
        self.id = json["id"].int64
        self.latitude = json["latitude"].number
        self.longitude = json["longitude"].number
        self.imageLogo = json["imageLogo"].string
        self.name = json["name"].string
        self.phoneNum = json["phoneNum"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let address = self.address {
            json["address"] = address
        }
        if let id = self.id {
            json["id"] = id
        }

        if let latitude = self.latitude {json["latitude"] = latitude}
        if let longitude = self.longitude {json["longitude"] = longitude}

        if let imageLogo = self.imageLogo {json["imageLogo"] = imageLogo}
        if let name = self.name {json["name"] = name}
        if let phoneNum = self.phoneNum {json["phoneNum"] = phoneNum}
        
        return json
    }
}
