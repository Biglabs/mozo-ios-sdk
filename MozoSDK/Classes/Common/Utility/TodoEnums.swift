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

    public var message: String {
        switch self {
        case .LOCATION_SERVICE_OFF: return "Location service is off."
        case .BLUETOOTH_OFF: return "Bluetooth is turned off."
        case .AIRDROP_NEARBY: return "Get MozoX from nearby airdrop events."
        case .PROMOTION_NEARBY: return "Purchased promotions nearby."
        case .VOUCHER_NEARBY: return "Purchased promotions nearby."
        case .VOUCHER_EXPIRED: return "Purchased promotions expiring soon."
        case .AIRDROP_EXPIRED: return "Airdrop events that will expire soon."
        case .LOW_MOZOX_RETAILER: return "Your wallet is almost out of MozoX."
        case .LOW_MOZOX_SHOPPER: return "Your wallet is almost out of MozoX."
        case .PROMOTION_EXPIRED: return "Promotions that will expire soon."
        case .AIRDROP_EMPTY: return "No planned airdrop events"
        case .PROMOTION_EMPTY: return "No planned promotions"
        case .UNSECURE_WALLET: return "Unsecure wallet"
        case .AIRDROP_OUT_OF_MOZOX: return "Airdrop events is almost out of MozoX."
        }
    }
}
public enum TodoServerityEnum: String {
    case HIGH = "HIGH"
    case NORMAL = "NORMAL"
    case LOW = "LOW"
}
