//
//  Enum+Protocol.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/18.
//

import Foundation
import SwiftyJSON

internal enum ServiceType: String {
    case DEVELOP
    case STAGING
    case PRODUCTION
    
    var api: String {
        switch self {
        case .PRODUCTION:
            return "gateway.mozocoin.io"
        case .STAGING:
            return "staging.gateway.mozocoin.io"
        default:
            return "gateway.cng.mozotoken.com"
        }
    }
    
    var socket: String {
        switch self {
        case .PRODUCTION:
            return "noti.mozocoin.io"
        case .STAGING:
            return "staging.noti.mozocoin.io"
        default:
            return "noti.cng.mozotoken.com"
        }
    }
    
    var auth: String {
        switch self {
        case .PRODUCTION:
            return "login.mozocoin.io"
        case .STAGING:
            return "staging.login.mozocoin.io"
        default:
            return "login.cng.mozotoken.com"
        }
    }
    
    
    var image: String {
        switch self {
        case .PRODUCTION:
            return "image.mozocoin.io"
        case .STAGING:
            return "staging.image.mozocoin.io"
        default:
            return "image.cng.mozotoken.com"
        }
    }
    
    var landingPage: String {
        switch self {
        case .PRODUCTION:
            return "mozotoken.com"
        case .STAGING:
            return "staging.mozotoken.com"
        default:
            return "cng.mozotoken.com"
        }
    }
}

public enum AppType: String {
    case Shopper = "shopper"
    case Retailer = "retailer"
    
    public var scheme: String {
        var suffix = ""
        switch MozoSDK.network {
        case .DevNet: suffix = "dev."
        case .TestNet: suffix = "staging."
        default: break
        }
        return "\(suffix)mozox.\(rawValue)"
    }
    
    public var appStoreUrl: String {
        switch self {
        case .Retailer: return "https://apps.apple.com/app/id1447347986"
        case .Shopper:  return "https://apps.apple.com/app/id1447452721"
        }
    }
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

public protocol ResponseObjectSerializable: AnyObject {
    init?(json: JSON)
}
