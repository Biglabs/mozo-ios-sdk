//
//  TodoDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/13/19.
//

import Foundation
public class TodoDisplayItem {
    public var severityEnum: TodoSeverityEnum
    public var todoEnum: TodoEnum
    
    public init() {
        todoEnum = .LOCATION_SERVICE_OFF
        severityEnum = .HIGH
    }
    
    public init(dto: TodoDTO) {
        todoEnum = TodoEnum(rawValue: dto.id ?? "") ?? .LOCATION_SERVICE_OFF
        severityEnum = TodoSeverityEnum(rawValue: dto.severity ?? "") ?? .HIGH
    }
}
