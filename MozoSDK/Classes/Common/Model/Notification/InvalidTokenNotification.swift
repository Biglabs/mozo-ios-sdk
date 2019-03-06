//
//  InvalidTokenNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/6/19.
//

import Foundation
import SwiftyJSON

public class InvalidTokenNotification : RdNotification {
    public var token: String?
    
    public required init? (json: SwiftyJSON.JSON) {
        var token = json["token"].string ?? ""
        if token.hasPrefix("bearer ") {
            token = String(token.dropFirst(7))
        }
        self.token = token
        super.init(json: json)
    }
}
