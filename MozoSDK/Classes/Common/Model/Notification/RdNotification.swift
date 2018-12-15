//
//  RdNotification.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/16/18.
//

import Foundation
import SwiftyJSON

public class RdNotification: ResponseObjectSerializable {
    public var event: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.event = json["event"].string
    }
}

public enum NotificationEventType: String {
    case BalanceChanged = "balance_changed"
    case AddressBookChanged = "address_book_changed"
    case Airdropped = "airdropped"
    case CustomerCame = "customer_came"
}
