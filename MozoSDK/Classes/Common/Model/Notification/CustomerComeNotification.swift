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
    public var isComeIn: Bool?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.phoneNo = json["phoneNo"].string
        self.isComeIn = json["isComeIn"].bool
        super.init(json: json)
    }
}
