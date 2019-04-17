//
//  AirdropInvite.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/17/19.
//

import Foundation
import SwiftyJSON

public class InviteNotification : BalanceNotification {
    public var inviteShopper: Bool?
    public var phoneNumSignUp: String?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.inviteShopper = json["inviteShopper"].bool
        self.phoneNumSignUp = json["phoneNumSignUp"].string
        super.init(json: json)
    }
}
