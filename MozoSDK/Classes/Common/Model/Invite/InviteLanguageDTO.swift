//
//  InviteLanguageDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/16/19.
//

import Foundation
import SwiftyJSON
public class InviteLanguageDTO : ResponseObjectSerializable {
    public var locale: String?
    public var name: String?
    public var imageUrl: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.locale = json["locale"].string
        self.name = json["name"].string
        self.imageUrl = json["imageUrl"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let locale = self.locale {
            json["locale"] = locale
        }
        if let name = self.name {json["name"] = name}
        if let imageUrl = self.imageUrl {json["imageUrl"] = imageUrl}
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [InviteLanguageDTO] {
        let array = json.array?.map({ InviteLanguageDTO(json: $0)! })
        return array ?? []
    }
}

