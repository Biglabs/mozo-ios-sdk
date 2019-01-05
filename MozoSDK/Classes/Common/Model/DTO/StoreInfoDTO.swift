//
//  StoreInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/6/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import SwiftyJSON

public class StoreInfoDTO : ResponseObjectSerializable {
    public var address: String?
    public var brandInfo: BrandInfoDTO?
    public var category: String?
    public var city: String?
    public var closeHour: Int?
    public var country: String?
    public var id: Int64?
    public var imageLogo: String?
    public var latitude: NSNumber?
    public var longitude: NSNumber?
    public var name: String?
    public var openHour: Int?
    public var phoneNum: String?
    public var state: String?
    public var zip: String?
    public var customerAirdropAmount: NSNumber?
    public var totalAirdropAmount: NSNumber?
    
    public var isFavorite: Bool?
    public var storeImages: [String]?
    public var hashTag: [String]?
    
    public required init(id: Int64){
        self.id = id
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.address = json["address"].string
        self.brandInfo = BrandInfoDTO(json: json["brandInfo"])
        self.id = json["id"].int64
        self.category = json["category"].string
        self.latitude = json["latitude"].number
        self.longitude = json["longitude"].number
        self.city = json["city"].string
        self.closeHour = json["closeHour"].int
        self.country = json["country"].string
        self.imageLogo = json["imageLogo"].string
        self.name = json["name"].string
        self.openHour = json["openHour"].int
        self.phoneNum = json["phoneNum"].string
        self.state = json["state"].string
        self.zip = json["zip"].string
        self.customerAirdropAmount = json["customerAirdropAmount"].number
        self.totalAirdropAmount = json["totalAirdropAmount"].number
        self.isFavorite = json["isFavorite"].bool
        self.hashTag = json["hashTag"].array?.filter({ $0.string != nil }).map({ $0.string! })
        self.storeImages = json["storeImages"].array?.filter({ $0.string != nil }).map({ $0.string! })
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let address = self.address {
            json["address"] = address
        }
        if let brandInfo = self.brandInfo {
            json["brandInfo"] = brandInfo.toJSON()
        }
        if let id = self.id {
            json["id"] = id
        }
        if let category = self.category {
            json["category"] = category
        }
        if let latitude = self.latitude {json["latitude"] = latitude}
        if let longitude = self.longitude {json["longitude"] = longitude}
        if let city = self.city {json["city"] = city}
        if let closeHour = self.closeHour {json["closeHour"] = closeHour}
        if let country = self.country {json["country"] = country}
        if let imageLogo = self.imageLogo {json["imageLogo"] = imageLogo}
        if let name = self.name {json["name"] = name}
        if let openHour = self.openHour {json["openHour"] = openHour}
        if let phoneNum = self.phoneNum {json["phoneNum"] = phoneNum}
        if let state = self.state {json["state"] = state}
        if let zip = self.zip {json["zip"] = zip}
        if let customerAirdropAmount = self.customerAirdropAmount {json["customerAirdropAmount"] = customerAirdropAmount}
        if let totalAirdropAmount = self.totalAirdropAmount {json["totalAirdropAmount"] = totalAirdropAmount}
        if let isFavorite = self.isFavorite {
            json["isFavorite"] = isFavorite
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [StoreInfoDTO] {
        let array = json.array?.map({ StoreInfoDTO(json: $0)! })
        return array ?? []
    }
}
