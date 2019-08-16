//
//  TodoSettingDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/13/19.
//

import Foundation
import SwiftyJSON

public class TodoSettingDTO: ResponseObjectSerializable {
    public var colors: JSON?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.colors = json["colors"]
    }
    
    public func colorFromServerity(_ todoServerity: TodoSeverityEnum) -> String {
        if let colors = self.colors {
            return colors[todoServerity.rawValue].string?.replace("#", withString: "") ?? "000000"
        }
        return "000000"
    }
}
