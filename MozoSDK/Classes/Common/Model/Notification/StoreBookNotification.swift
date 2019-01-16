//
//  StoreBookNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/15/19.
//

import Foundation
import SwiftyJSON

public class StoreBookNotification : RdNotification {
    public var action: String?
    public var data: StoreBookDTO?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.action = json["action"].string
        self.data = StoreBookDTO(json: json["data"])
        super.init(json: json)
    }
}
