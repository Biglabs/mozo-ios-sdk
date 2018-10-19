//
//  AddressBookNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/16/18.
//

import Foundation
import SwiftyJSON

public class AddressBookNotification : RdNotification {
    public var action: String?
    public var data: [AddressBookDTO]?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.action = json["action"].string
        self.data = json["data"].array?.filter({ AddressBookDTO(json: $0) != nil }).map({ AddressBookDTO(json: $0)! })
        super.init(json: json)
    }
}

public enum AddressBookNotificationType : String {
    case Create = "create"
    case Update = "update"
    case Delete = "delete"
}
