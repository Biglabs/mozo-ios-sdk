//
//  WSMessageDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/16/18.
//

import Foundation
import SwiftyJSON

public class WSMessage: ResponseObjectSerializable {
    public var content: String?
    public var message: String?
    public var channel: String?
    public var messageType: String?
    public var time: Int64?
    public var uuid: String?
    
    public required init(content: String, message: String, channel: String, messageType: String, time: Int64, uuid: String){
        self.content = content
        self.message = message
        self.channel = channel
        self.messageType = messageType
        self.time = time
        self.uuid = uuid
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.content = json["content"].string
        self.message = json["message"].string
        self.channel = json["channel"].string
        self.messageType = json["messageType"].string
        self.time = json["time"].int64
        self.uuid = json["uuid"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let message = self.message {
            json["message"] = message
        }
        if let channel = self.channel {
            json["channel"] = channel
        }
        if let messageType = self.messageType {
            json["messageType"] = messageType
        }
        if let time = self.time {
            json["time"] = time
        }
        if let uuid = self.uuid {
            json["uuid"] = uuid
        }
        return json
    }
}
