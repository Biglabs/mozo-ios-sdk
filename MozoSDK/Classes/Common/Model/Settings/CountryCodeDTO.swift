//
//  CountryCodeDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/5/19.
//

import Foundation
import SwiftyJSON
public class CountryCodeDTO : ResponseObjectSerializable {
    public var country: String?
    public var countryCode: String?
    public var isoCode: String?
    public var urlImage: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.country = json["country"].string
        self.countryCode = json["countryCode"].string
        self.isoCode = json["isoCode"].string
        self.urlImage = json["urlImage"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let country = self.country {
            json["country"] = country
        }
        if let countryCode = self.countryCode {json["countryCode"] = countryCode}
        if let isoCode = self.isoCode {json["isoCode"] = isoCode}
        if let urlImage = self.urlImage {json["urlImage"] = urlImage}
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [CountryCodeDTO] {
        let array = json.array?.map({ CountryCodeDTO(json: $0)! })
        return array ?? []
    }
}
