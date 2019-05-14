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

public enum NotificationCategoryType: String {
    case Balance_Changed_Received = "balance_changed_received"
    case Balance_Changed_Sent = "balance_changed_sent"
    case Airdropped = "airdropped"
    case AirdropInvite = "airdrop_invite"
    case Customer_Came_In = "customer_came_in"
    case Customer_Came_Out = "customer_came_out"
    
    case Default = ""
    
    public var summaryFormat: String {
        switch self {
        case .Balance_Changed_Received: return "%u MozoX total received"
        case .Balance_Changed_Sent: return "%u MozoX total sent"
        case .Airdropped: return "%u MozoX total received from Airdrop Events"
        case .AirdropInvite: return "%u friends joined MozoX"
        case .Customer_Came_In: return "%u customer arrived"
        case .Customer_Came_Out: return "%u customer departed"
        case .Default: return rawValue
        }
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
}
