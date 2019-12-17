//
//  AirdropEventTypeEnums.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/16/19.
//

import Foundation
public enum AirdropEventType: String {
    case ACTIVE = "ACTIVE"
    case WAITING = "WAITING"
    
    public var displayText : String {
        switch self {
        case .ACTIVE: return "Active Airdrop Events"
        case .WAITING: return "Waiting Airdrop Events"
        }
    }
}
