//
//  TodoData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/14/20.
//

import Foundation
import SwiftyJSON
public class TodoData: ResponseObjectSerializable {
    public var link: String?
    public var messageId: Int64?
    public var customTitle: String?
    public var customAction: String?
    
    public required init?(json: JSON) {
        self.link = json["link"].string
        self.messageId = json["messageId"].int64
        self.customTitle = json["customTitle"].string
        self.customAction = json["customAction"].string
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let link = self.link {
            json["link"] = link
        }
        if let messageId = self.messageId {
            json["messageId"] = messageId
        }
        if let title = self.customTitle {
            json["customTitle"] = title
        }
        if let action = self.customAction {
            json["customAction"] = action
        }
        return json
    }
}
