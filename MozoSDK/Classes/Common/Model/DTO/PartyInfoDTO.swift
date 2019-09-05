//
//  PartyInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/27/19.
//

import Foundation
import SwiftyJSON
public class PartyInfoDTO: ResponseObjectSerializable {
    
    public var storeName: String?
    public var partyName: String?
    public var coverImage: String?
    
    public required init(storeName: String, partyName: String, coverImage: String) {
        self.storeName = storeName
        self.partyName = partyName
        self.coverImage = coverImage
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.storeName = json["storeName"].string
        self.partyName = json["partyName"].string
        self.coverImage = json["coverImage"].string
    }
}
