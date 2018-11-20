//
//  CustomerComeNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/16/18.
//

import Foundation
import SwiftyJSON

public class CustomerComeNotification : RdNotification {
    public var phoneNo: String?
    public var comeIn: Bool?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.phoneNo = json["phoneNo"].string
        self.comeIn = json["comeIn"].bool
        super.init(json: json)
    }
}
