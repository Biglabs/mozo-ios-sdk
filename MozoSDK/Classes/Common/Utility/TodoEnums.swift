//
//  TodoEnums.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/13/19.
//

import Foundation
public enum TodoEnum: String {
    case LOCATION_SERVICE_OFF = "LOCATION_SERVICE_OFF"
    case BLUETOOTH_OFF = "BLUETOOTH_OFF"
    case AIRDROP_NEARBY = "AIRDROP_NEARBY"
    case PROMOTION_NEARBY = "PROMOTION_NEARBY"
    case VOUCHER_NEARBY = "VOUCHER_NEARBY"
    case VOUCHER_EXPIRED = "VOUCHER_EXPIRED"
    case AIRDROP_EXPIRED = "AIRDROP_EXPIRED"
    case LOW_MOZOX_RETAILER = "LOW_MOZOX_RETAILER"
    case LOW_MOZOX_SHOPPER = "LOW_MOZOX_SHOPPER"
    case PROMOTION_EXPIRED = "PROMOTION_EXPIRED"
    case AIRDROP_EMPTY = "AIRDROP_EMPTY"
    case PROMOTION_EMPTY = "PROMOTION_EMPTY"
    case UNSECURE_WALLET = "UNSECURE_WALLET"
    case AIRDROP_OUT_OF_MOZOX = "AIRDROP_OUT_OF_MOZOX"
    case MESSAGE_NEW = "MESSAGE_NEW"
    case NEW_SPECIAL_PROMOTION = "NEW_SPECIAL_PROMOTION"
    case LUCKY_DRAW_AWARD = "LUCKY_DRAW_AWARD"
    case LUCKY_DRAW_NOTICE = "LUCKY_DRAW_NOTICE"

    public var message: String {
        switch self {
            case .LOCATION_SERVICE_OFF: return "Location service is off 🗺"
            case .BLUETOOTH_OFF: return "Bluetooth is tuned off 😔..."
            case .AIRDROP_NEARBY: return "todo_msg_get_nearby_airdrop"
            case .PROMOTION_NEARBY: return "Interesting promotions nearby 🤩"
            case .VOUCHER_NEARBY: return "Purchased promotions nearby 🤣"
            case .VOUCHER_EXPIRED: return "Purchased promotions expiring soon 😣"
            case .AIRDROP_EXPIRED: return "Airdrop events that will expire soon ⏳"
            case .LOW_MOZOX_RETAILER: return "todo_msg_wallet_almost_out_of_mozo"
            case .LOW_MOZOX_SHOPPER: return "todo_msg_wallet_almost_out_of_mozo"
            case .PROMOTION_EXPIRED: return "Promotions that will expire soon 👌"
            case .AIRDROP_EMPTY: return "No planned airdrop events 😐"
            case .PROMOTION_EMPTY: return "No planned promotions 😐"
            case .UNSECURE_WALLET: return "Unsecure wallet 😱"
            case .AIRDROP_OUT_OF_MOZOX: return "todo_msg_event_almost_out_of_mozo"
            case .MESSAGE_NEW: return "todo_msg_event_message_new"
            case .NEW_SPECIAL_PROMOTION: return "todo_msg_event_promo_special"
            case .LUCKY_DRAW_AWARD: return "todo_msg_event_lucky_award"
            case .LUCKY_DRAW_NOTICE: return "todo_msg_event_lucky_notice"
        }
    }
    
    public var actionText: String {
        switch self {
            case .LOCATION_SERVICE_OFF: return "Turn on for better experience →"
            case .BLUETOOTH_OFF: return "todo_action_turn_on_bluetooth"
            case .AIRDROP_NEARBY: return "todo_action_discover_stores"
            case .PROMOTION_NEARBY: return "Discover your bookmarked promotions →"
            case .VOUCHER_NEARBY: return "Discover your purchased promotions →"
            case .VOUCHER_EXPIRED: return "Discover your purchased promotions →"
            case .AIRDROP_EXPIRED: return "Review and create a new airdrop event →"
            case .LOW_MOZOX_RETAILER: return "todo_action_buy_mozo"
            case .LOW_MOZOX_SHOPPER: return "todo_action_discover_stores"
            case .PROMOTION_EXPIRED: return "Create a new promotion →"
            case .AIRDROP_EMPTY: return "Create to increase foot traffic →"
            case .PROMOTION_EMPTY: return "Create promotion →"
            case .UNSECURE_WALLET: return "Set up your own PIN →"
            case .AIRDROP_OUT_OF_MOZOX: return "todo_action_review_add_more_mozo"
            case .MESSAGE_NEW: return "todo_action_event_message_new"
            case .NEW_SPECIAL_PROMOTION: return "todo_action_event_promo_special"
            case .LUCKY_DRAW_AWARD: return "todo_action_event_lucky_award"
            case .LUCKY_DRAW_NOTICE: return "todo_action_event_lucky_notice"
        }
    }
}
public enum TodoSeverityEnum: String {
    case HIGH = "HIGH"
    case NORMAL = "NORMAL"
    case LOW = "LOW"
}
