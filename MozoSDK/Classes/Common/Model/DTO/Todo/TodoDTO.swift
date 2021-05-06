//
//  TodoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/13/19.
//

import Foundation
import SwiftyJSON

public class TodoDTO: ResponseObjectSerializable {
    public var idKey: TodoEnum = .CUSTOM
    public var id: String? {
        didSet {
            idKey = TodoEnum(rawValue: self.id ?? "") ?? idKey
        }
    }
    public var data: TodoData?
    public var priority: Int?
    
    public var severityKey: TodoSeverityEnum = .NORMAL
    public var severity: String? {
        didSet {
            severityKey = TodoSeverityEnum(rawValue: self.severity ?? "") ?? severityKey
        }
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].string
        self.idKey = TodoEnum(rawValue: self.id ?? "") ?? self.idKey
        
        self.data = TodoData(json: json["data"])
        self.priority = json["priority"].int
        self.severity = json["severity"].string
        self.severityKey = TodoSeverityEnum(rawValue: self.severity ?? "") ?? self.severityKey
    }
    
    public required init?() {}
    
    public func displayTitle() -> String? {
        switch idKey {
        case .CUSTOM:
            return data?.customTitle
        default:
            return data?.customTitle ?? idKey.message.localized
        }
    }
    
    public func displayAction() -> String? {
        switch idKey {
        case .CUSTOM:
            return data?.customAction
        default:
            return data?.customAction ?? idKey.actionText.localized
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let keyReminder = self.id {
            json["keyReminder"] = keyReminder
        }
        if let data = self.data {
            json["data"] = data.toJSON()
        }
        if let priority = self.priority {
            json["priority"] = priority
        }
        if let serverity = self.severity {
            json["severity"] = serverity
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [TodoDTO] {
        let array = json.array?.map({ TodoDTO(json: $0)! })
        return array ?? []
    }
}
