//
//  LuckyDrawNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/14/20.
//

import Foundation
import SwiftyJSON
public class LuckyDrawNotification : RdNotification {
    public var messageId: Int64?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.messageId = json["messageId"].int64
        super.init(json: json)
    }
}
