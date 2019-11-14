//
//  TopUpReasonEnum.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/6/19.
//

import Foundation
public enum TopUpReasonEnum: String {
    case PARKING_TICKET = "PARKING_TICKET"
    case TOP_UP_WITHDRAW = "TOP_UP_WITHDRAW"
    case TOP_UP_ADD_MORE = "TOP_UP_ADD_MORE"
    
    var displayText: String {
        switch self {
        case .PARKING_TICKET:
            return "Parking fee"
        case .TOP_UP_WITHDRAW:
            return "Withdraw"
        case .TOP_UP_ADD_MORE:
            return "Top up"
        }
    }
}
