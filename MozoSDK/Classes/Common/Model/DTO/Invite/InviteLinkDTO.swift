//
//  InviteLinkDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/16/19.
//

import Foundation
import SwiftyJSON
public class InviteLinkDTO : ResponseObjectSerializable {
    public var inviteRetailerLink: String?
    public var inviteShopperLink: String?
    public var locale: String?
    public var rewardRetailer: NSNumber?
    public var rewardShopper: NSNumber?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.inviteRetailerLink = json["inviteRetailerLink"].string
        self.inviteShopperLink = json["inviteShopperLink"].string
        self.locale = json["locale"].string
        self.rewardRetailer = json["rewardRetailer"].number
        self.rewardShopper = json["rewardShopper"].number
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let inviteRetailerLink = self.inviteRetailerLink {
            json["inviteRetailerLink"] = inviteRetailerLink
        }
        if let inviteShopperLink = self.inviteShopperLink {
            json["inviteShopperLink"] = inviteShopperLink
        }
        if let locale = self.locale {
            json["locale"] = locale
        }
        if let rewardRetailer = self.rewardRetailer {json["rewardRetailer"] = rewardRetailer}
        if let rewardShopper = self.rewardShopper {json["rewardShopper"] = rewardShopper}
        return json
    }
}
