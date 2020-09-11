//
//  TodoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/13/19.
//

import Foundation
import SwiftyJSON

public class TodoDTO: ResponseObjectSerializable {
    public var id: String?
    public var data: TodoData?
    public var priority: Int?
    public var severity: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].string
        self.data = TodoData(json: json["data"])
        self.priority = json["priority"].int
        self.severity = json["severity"].string
    }
    
    public required init?() {}
    
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
