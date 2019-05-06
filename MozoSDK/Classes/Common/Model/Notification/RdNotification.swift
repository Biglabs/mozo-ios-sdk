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
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let event = self.event {
            json["event"] = event
        }
        return json
    }
}

public enum NotificationEventType: String {
    case BalanceChanged = "balance_changed"
    case AddressBookChanged = "address_book_changed"
    case StoreBookAdded = "store_book_added"
    case Airdropped = "airdropped"
    case CustomerCame = "customer_came"
    
    case InvalidToken = "invalid_token"
    case ConvertOnchainToOffchain = "convert_onchain_to_offchain"
    case AirdropInvite = "airdrop_invite"
    
    case ProfileChanged = "profile_changed"
    
    public var summaryFormat: String {
        switch self {
        case .BalanceChanged: return ""
        case .Airdropped: return ""
        case .AirdropInvite: return ""
        case .CustomerCame: return ""
        default:
            return ""
        }
    }
}
