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
    
    public required init?(json: JSON) {
        self.link = json["link"].string
        self.messageId = json["messageId"].int64
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let link = self.link {
            json["link"] = link
        }
        if let messageId = self.messageId {
            json["messageId"] = messageId
        }
        return json
    }
}
