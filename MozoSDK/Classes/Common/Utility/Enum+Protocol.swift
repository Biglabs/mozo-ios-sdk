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
            return "gateway.mozotoken.com"
        case .STAGING:
            return "gateway.staging.mozotoken.com"
        default:
            return "cng.gateway.mozotoken.com"
        }
    }
    
    var socket: String {
        switch self {
        case .PRODUCTION:
            return "noti.mozotoken.com"
        case .STAGING:
            return "noti.staging.mozotoken.com"
        default:
            return "noti.cng.mozotoken.com"
        }
    }
    
    var auth: String {
        switch self {
        case .PRODUCTION:
            return "login.mozotoken.com"
        case .STAGING:
            return "login.staging.mozotoken.com"
        default:
            return "login.cng.mozotoken.com"
        }
    }
    
    
    var image: String {
        switch self {
        case .PRODUCTION:
            return "image.mozotoken.com"
        case .STAGING:
            return "image.staging.mozotoken.com"
        default:
            return "image.cng.mozotoken.com"
        }
    }
    
    var landingPage: String {
        switch self {
        case .PRODUCTION:
            return "mozocoin.io"
        case .STAGING:
            return "staging.mozocoin.io"
        default:
            return "cng.mozocoin.io"
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
