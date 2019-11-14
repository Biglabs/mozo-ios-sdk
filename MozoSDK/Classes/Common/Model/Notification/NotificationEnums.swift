//
//  NotificationEnums.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/15/19.
//

import Foundation

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
        case .Balance_Changed_Received: return "%u more MozoX received"
        case .Balance_Changed_Sent: return "%u more MozoX sent"
        case .Airdropped: return "%u more MozoX received from Airdrop Events"
        case .AirdropInvite: return "%u more friends joined MozoX"
        case .Customer_Came_In: return "%u more customers arrived"
        case .Customer_Came_Out: return "%u more customers departed"
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
    
    case AirdropFounder = "airdrop_founder"
    case AirdropSignup = "airdrop_signup"
    case AirdropTopRetailer = "airdrop_top_retailer"
    
    case PromotionUsed = "promotion_used"
    case PromotionPurchased = "promotion_purchased"
    
    case GroupBroadcast = "group_broadcast"
}

