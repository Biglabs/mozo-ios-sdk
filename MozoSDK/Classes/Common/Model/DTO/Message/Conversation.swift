//
//  Conversation.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/3/20.
//

import Foundation
import SwiftyJSON
public class Conversation: ResponseObjectSerializable {
    
    public enum Action : String {
        case ACCEPT = "ACCEPT"
        case REJECT = "REJECT"
        
        public var display : String {
            switch self {
            case .ACCEPT: return "messages_action_accept"
            case .REJECT: return "messages_action_reject"
            }
        }
    }
    
    public enum Status : String {
        case NORMAL = "NORMAL"
        case INVITED = "INVITED"
        case BLOCKED = "BLOCKED"
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
    
    public func showAccept() -> Bool {
        return info?.getStatus() == .INVITED || info?.getStatus() == .BLOCKED
    }
    
    public func showReject() -> Bool {
        return info?.getStatus() == .INVITED || info?.getStatus() == .NORMAL
    }
    
    public func toggleAccept() -> String {
        self.info?.status = Status.NORMAL.rawValue
        return Action.ACCEPT.rawValue
    }
    
    public func toggleReject() -> String {
        self.info?.status = Status.BLOCKED.rawValue
        return Action.REJECT.rawValue
    }
    
    public class Info: ResponseObjectSerializable {
        public var id: Int64?
        public var status: String?
        public var timeCreateOn: Int64?
        public var canReply: Bool? = false
        public var read: Bool? = false
        
        public required init?(json: JSON) {
            self.id = json["id"].int64
            self.status = json["status"].string
            self.timeCreateOn = json["timeCreateOn"].int64
            self.canReply = json["canReply"].bool
            self.read = json["read"].bool
        }
        
        public func getStatus() -> Status {
            return self.status == nil ? .NORMAL : (Status.init(rawValue: self.status!.uppercased()) ?? .NORMAL)
        }
    }
}
