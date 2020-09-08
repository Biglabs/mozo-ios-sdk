//
//  Conversation.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/3/20.
//

import Foundation
import SwiftyJSON
public class Conversation: ResponseObjectSerializable {
    
    public enum Status : String {
        case NORMAL = "NORMAL"
        case INVITED = "INVITED"
        case BLOCKED = "BLOCKED"
        case ACCEPT = "ACCEPT"
        case REJECT = "REJECT"
    }
    
    public var branch: BranchInfoDTO?
    public var info: Info?
    public var chatItem: ConversationMessage?
    
    public required init?(json: JSON) {
        self.branch = BranchInfoDTO(json: json["branch"])
        self.info = Info(json: json["contactItem"])
        if json["chatItem"].type != .null {
            self.chatItem = ConversationMessage(json: json["chatItem"])
        }
    }
    
    public func getTimeCreatedDisplay() -> String {
        var time = Date().timeIntervalSince1970
        if let chatTime = chatItem?.timeCreatedOn {
            time = Double(chatTime)
        } else if let infoTime = info?.timeCreateOn {
            time = Double(infoTime)
        }
        return DisplayUtils.formatMessageTime(time: time)
    }
    
    public class Info: ResponseObjectSerializable {
        public var id: Int?
        public var status: String?
        public var timeCreateOn: Int64?
        public var canReply: Bool? = false
        public var read: Bool? = false
        
        public required init?(json: JSON) {
            self.id = json["id"].int
            self.status = json["status"].string
            self.timeCreateOn = json["timeCreateOn"].int64
            self.canReply = json["canReply"].bool
            self.read = json["read"].bool
        }
    }
}
