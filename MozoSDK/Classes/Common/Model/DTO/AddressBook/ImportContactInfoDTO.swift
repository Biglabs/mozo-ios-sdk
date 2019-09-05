//
//  ImportContactInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/27/19.
//

import Foundation
import SwiftyJSON
public class ImportContactInfoDTO: ResponseObjectSerializable {
    
    public var contactInfos: [ContactInfoDTO]?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.contactInfos = json["contactInfos"].array?.map({ ContactInfoDTO(json: $0)! })
    }
    
    public required init(contactInfos: [ContactInfoDTO]){
        self.contactInfos = contactInfos
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let contactInfos = self.contactInfos {
            json["contactInfos"] = contactInfos.map({$0.toJSON()})
        }
        return json
    }
}
