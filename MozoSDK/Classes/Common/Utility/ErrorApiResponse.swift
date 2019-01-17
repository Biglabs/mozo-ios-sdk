//
//  ErrorApiResponse.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/9/19.
//

import Foundation
public enum ErrorApiResponse: String {
    // COMMON
    case INTERNAL_ERROR = "INTERNAL_ERROR"
    case UNAUTHORIZED_ACCESS = "UNAUTHORIZED_ACCESS"
    case INVALID_USER_TOKEN = "INVALID_USER_TOKEN"
    case INVALID_REQUEST = "INVALID_REQUEST"
    // STORE
    case STORE_RETAILER_BEACON_UNAUTHORIZED_ACCESS = "STORE_RETAILER_BEACON_UNAUTHORIZED_ACCESS"
    case STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT = "STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT"
    case STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE = "STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE"

    case STORE_RETAILER_UNAUTHORIZED_ACCESS = "STORE_RETAILER_UNAUTHORIZED_ACCESS"
    case STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS = "STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS"
    case STORE_SALE_PERSON_UNAUTHORIZED_ACCESS_REMOVED = "STORE_SALE_PERSON_UNAUTHORIZED_ACCESS_REMOVED"
    
    case STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST = "STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST"
    case STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD = "STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD"
    case STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY = "STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY"
    case STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY = "STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY"
    case STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY = "STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY"
    case STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT = "STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT"
    case STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT = "STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT"
    case STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY = "STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY"
    
    case STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT = "STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT"
    case STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE = "STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE"
    // SOLOMON
    case SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS = "SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS"
    case SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS = "SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS"
    
    case SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED = "SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED"
    case SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET = "SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET"
    case SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD = "SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD"
        
    case SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS = "SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS"
    case SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS = "SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS"
    case TRANSACTION_ADDRESS_STATUS_PENDING = "TRANSACTION_ADDRESS_STATUS_PENDING"
    case TRANSACTION_ERROR_NONCE_TOO_LOW = "TRANSACTION_ERROR_NONCE_TOO_LOW"
    case TRANSACTION_ERROR_SEND_TX = "TRANSACTION_ERROR_SEND_TX"
    
    case SOLOMON_FATAL_USER_NO_PROFILE = "SOLOMON_FATAL_USER_NO_PROFILE"
    
    public var description: String {
        switch self {
        case .INTERNAL_ERROR: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .UNAUTHORIZED_ACCESS: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .INVALID_USER_TOKEN: return "Your session has expired. Please login again"
        case .INVALID_REQUEST: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS: return "Your wallet was updated but did not sync with your current device. Please restore your wallet first."
        case .SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS: return "The destination wallet was not found. Please recheck the wallet address or try another wallet address"
        case .SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS: return "Your wallet was updated but did not sync with your current device. Please restore your wallet first."
        case .TRANSACTION_ADDRESS_STATUS_PENDING: return "Something is wrong with your account status. Please try again."
        case .TRANSACTION_ERROR_NONCE_TOO_LOW: return "Something is wrong with your account status. Please try again."
        case .TRANSACTION_ERROR_SEND_TX: return "Something is wrong with your account status. Please try again."
        case .SOLOMON_FATAL_USER_NO_PROFILE: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"

        case .STORE_RETAILER_UNAUTHORIZED_ACCESS: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .STORE_SALE_PERSON_UNAUTHORIZED_ACCESS_REMOVED: return "Your account has been deactivated temporarily. Please sign in with other account or contact us for more information (phone + email)"

        case .STORE_RETAILER_BEACON_UNAUTHORIZED_ACCESS: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT: return "Cannot connect to MozoX servers. Please contact us for more information (email + phone)"
        case .STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE: return "This beacon has been registered to another store. Please contact us for more information (email + phone)"

        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST: return "Event start date must be at least 10 minutes later than current time. Please check your input."
        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD: return "Event start date must be earlier than its end date. Please check your input."
        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY: return "Invalid Airdrop start time - end time."
        case .STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY: return "Invalid Airdrop start time - end time."
        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY: return "The applied \"from\" hour must be earlier than the applied \"to\" hour. Please check your input."
        case .STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT: return "\"Frequency\" is the minimum duration of time from the previous airdrop to a Shopper before the Shopper can collect more MozoX tokens during the same airdrop event.\n\"Frequency\" must be greater than 30 minutes*. Please check your input. (*We recommend setting \"Frequency\" at  24 hours)."
        case .STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT: return "Incorrect total amount of MozoX tokens to be airdropped. Please check your input."
        case .STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY: return "Incorrect amount of MozoX tokens to be airdropped to each Shopper visiting your store. Please check your input."
    

        case .STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT: return rawValue
        case .STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE: return rawValue
        }
    }
    
    public var connectionError: ConnectionError {
        switch self {
        case .INTERNAL_ERROR:
            return .apiError_INTERNAL_ERROR
        case .UNAUTHORIZED_ACCESS: return .apiError_UNAUTHORIZED_ACCESS
        case .INVALID_USER_TOKEN: return .apiError_INVALID_USER_TOKEN
        case .INVALID_REQUEST: return .apiError_INVALID_REQUEST
        case .SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS:
            return .apiError_SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS
        case .SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS:
            return .apiError_SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS
        case .SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED:
            return .apiError_SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED
        case .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET:
            return .apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET
        case .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD:
            return .apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD
        case .SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS:
            return .apiError_SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS
        case .SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS:
            return .apiError_SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS
        case .TRANSACTION_ADDRESS_STATUS_PENDING:
            return .apiError_TRANSACTION_ADDRESS_STATUS_PENDING
        case .TRANSACTION_ERROR_NONCE_TOO_LOW:
            return .apiError_TRANSACTION_ERROR_NONCE_TOO_LOW
        case .TRANSACTION_ERROR_SEND_TX:
            return .apiError_TRANSACTION_ERROR_SEND_TX
        case .SOLOMON_FATAL_USER_NO_PROFILE: return .apiError_SOLOMON_FATAL_USER_NO_PROFILE
        
        case .STORE_RETAILER_UNAUTHORIZED_ACCESS: return .apiError_STORE_RETAILER_UNAUTHORIZED_ACCESS
        case .STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS:
            return .apiError_STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS
        case .STORE_SALE_PERSON_UNAUTHORIZED_ACCESS_REMOVED:
            return .apiError_STORE_SALE_PERSON_UNAUTHORIZED_ACCESS_REMOVED
            
        case .STORE_RETAILER_BEACON_UNAUTHORIZED_ACCESS: return .apiError_STORE_RETAILER_BEACON_UNAUTHORIZED_ACCESS
        case .STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT: return .apiError_STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT
        case .STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE: return .apiError_STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE
            
        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST
        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD
        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY
        case .STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY
        case .STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY
        case .STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT
        case .STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT
        case .STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY: return .apiError_STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY
            
        case .STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT: return .apiError_STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT
        case .STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE: return .apiError_STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE
        }
    }
}
