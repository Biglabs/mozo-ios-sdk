//
//  InviteLinkDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/16/19.
//

import Foundation
import SwiftyJSON
public class InviteLinkDTO : ResponseObjectSerializable {
    public var inviteLink: String?
    public var locale: String?
    public var reward: NSNumber?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.inviteLink = json["inviteLink"].string
        self.locale = json["locale"].string
        self.reward = json["reward"].number
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let inviteRetailerLink = self.inviteLink {
            json["inviteLink"] = inviteRetailerLink
        }
        if let locale = self.locale {
            json["locale"] = locale
        }
        if let reward = self.reward {json["reward"] = reward}
        return json
    }
}
