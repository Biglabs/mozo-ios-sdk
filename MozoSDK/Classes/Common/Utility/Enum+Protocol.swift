//
//  Enum+Protocol.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/18.
//

import Foundation
import SwiftyJSON

public enum MediaType: String {
    case APPLICATION_JSON = "application/json"
    case APPLICATION_FORM_URLENCODED = "application/x-www-form-urlencoded"
}

public enum ServiceType: String {
    case DEV = "dev."
    case STAGING = "staging."
    case PRODUCTION = ""
    
    public var socket: String {
        switch self {
        case .DEV: return "dev.noti.mozocoin.io"
        case .STAGING: return "staging.noti.mozocoin.io"
        case .PRODUCTION: return "noti.mozocoin.io"
        }
    }
}

public enum AppType: String {
    case Shopper = "shopper"
    case Retailer = "retailer"
}

enum TransactionDisplayContactEnum: Int {
    case NoDetail = 0
    case AddressBookDetail = 1
    case StoreBookDetail = 2
    
    var icon: String {
        switch self {
        case .StoreBookDetail: return "ic_store"
        default: return "ic_user"
        }
    }
}

public protocol ResponseObjectSerializable: class {
    init?(json: JSON)
}
