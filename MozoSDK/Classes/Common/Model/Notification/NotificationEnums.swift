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
    case Agenda = "agenda"
    case Before_Event = "before_event"
    case In_Store_Guide = "in_store_guide"
    case Hackathon_Result = "hackathon_result"
    case Notice = "notice"
    case Feedback = "feed_back"
    
    case Default = ""
    
    public var identifier: String {
        return "mozoActionCategory_\(rawValue)"
    }
    
    public var summaryFormat: String {
        switch self {
        case .Balance_Changed_Received: return "%u more MozoX received"
        case .Balance_Changed_Sent: return "%u more MozoX sent"
        case .Airdropped: return "%u more MozoX received from Airdrop Events"
        case .AirdropInvite: return "%u more friends joined MozoX"
        case .Customer_Came_In: return "%u more customers arrived"
        case .Customer_Came_Out: return "%u more customers departed"
        case .Default: return rawValue
        default: return ""
        }
    }
    
    var needGroup: Bool {
        switch self {
        case .Agenda, .Before_Event, .In_Store_Guide, .Hackathon_Result, .Notice, .Feedback, .Default: return false
        default: return true
        }
    }
    
    var isRemote: Bool {
        switch self {
        case .Agenda, .Before_Event, .In_Store_Guide, .Hackathon_Result, .Notice, .Feedback: return true
        default: return false
        }
    }
}

public enum NotificationActionType: String {
    case Agenda_Info = "agenda_info"
    case Agenda_Parking_Guide = "agenda_parking_guide"
    case Agenda_Venue = "agenda_venue"
    
    case Before_Event_Hall_Layout_Guide = "before_event_hall_layout_guide"
    case Before_Event_Parking_Ticket = "before_event_parking_ticket"
    
    case In_Store_Hall_Layout_Guide = "in_store_hall_layout_guide"
    case In_Store_Safety_Guide = "in_store_safety_guide"
    
    case Hackathon_Result = "hackathon_result"
    
    case Notice = "notice"

    case Feed_Back_No_Thanks = "feed_back_no_thanks"
    case Feed_Back_Start = "feed_back_start"
    
    public var identifier: String {
        return "action_\(rawValue)"
    }
    
    public var name: String {
        switch self {
        case .Agenda_Info: return "Info"
        case .Agenda_Parking_Guide: return "Guide"
        case .Agenda_Venue: return "Venue"
        case .Before_Event_Hall_Layout_Guide, .In_Store_Hall_Layout_Guide: return "Hall Layout guide"
        case .In_Store_Safety_Guide: return "Safety guide"
        case .Hackathon_Result: return "View"
        case .Before_Event_Parking_Ticket: return "Parking ticket"
        case .Notice: return "View"
        case .Feed_Back_No_Thanks: return "No. Thanks"
        case .Feed_Back_Start: return "Start"
        }
    }
    
    /* Notification Custom Actions
    "NOTIFICATION_INFO_LOCALE_KEY" = "Info";
    "NOTIFICATION_VENUE_LOCALE_KEY" = "Venue";
    "NOTIFICATION_GUIDE_LOCALE_KEY" = "Guide";
    "NOTIFICATION_HALL_LAYOUT_GUIDE_LOCALE_KEY" = "Hall Layout guide";
    "NOTIFICATION_PARKING_TICKET_LOCALE_KEY" = "Parking ticket";
    "NOTIFICATION_SAFETY_GUIDE_LOCALE_KEY" = "Safety guide";
    "NOTIFICATION_VIEW_LOCALE_KEY" = "View";
    "NOTIFICATION_NO_THANKS_LOCALE_KEY" = "No. Thanks";
    "NOTIFICATION_START_LOCALE_KEY" = "Start";
    */
    
    public var localizedTitle: String {
        switch self {
        case .Agenda_Info: return "NOTIFICATION_INFO_LOCALE_KEY".localized
        case .Agenda_Parking_Guide: return "NOTIFICATION_GUIDE_LOCALE_KEY".localized
        case .Agenda_Venue: return "NOTIFICATION_VENUE_LOCALE_KEY".localized
        case .Before_Event_Hall_Layout_Guide, .In_Store_Hall_Layout_Guide: return "NOTIFICATION_HALL_LAYOUT_GUIDE_LOCALE_KEY".localized
        case .In_Store_Safety_Guide: return "NOTIFICATION_SAFETY_GUIDE_LOCALE_KEY".localized
        case .Hackathon_Result: return "NOTIFICATION_VIEW_LOCALE_KEY".localized
        case .Before_Event_Parking_Ticket: return "NOTIFICATION_PARKING_TICKET_LOCALE_KEY".localized
        case .Notice: return "NOTIFICATION_VIEW_LOCALE_KEY".localized
        case .Feed_Back_No_Thanks: return "NOTIFICATION_NO_THANKS_LOCALE_KEY".localized
        case .Feed_Back_Start: return "NOTIFICATION_START_LOCALE_KEY".localized
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

