//
//  ConversationMessage.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/3/20.
//

import Foundation
import SwiftyJSON
public class ConversationMessage: ResponseObjectSerializable {
    public var id: Int?
    public var message: String?
    public var images: [String]?
    public var timeCreatedOn: Int64?
    public var timeRead: Int64?
    public var userSend: Bool? = false
    
    public required init?(json: JSON) {
        self.id = json["id"].int
        self.message = json["message"].string
        self.images = json["images"].array?.filter({ $0.string != nil }).map({ $0.string! })
        self.timeCreatedOn = json["timeCreatedOn"].int64
        self.timeRead = json["timeRead"].int64
        self.userSend = json["userSend"].bool
    }
    
    public func getTimeCreatedDisplay() -> String {
        var time = Date().timeIntervalSince1970
        if let infoTime = timeCreatedOn {
            time = Double(infoTime)
        }
        return DisplayUtils.formatMessageTime(time: time)
    }
}
