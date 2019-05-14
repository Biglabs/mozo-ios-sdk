//
//  Error.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/18.
//

import Foundation
public enum ConnectionError: Error {
    case network(error: Error)
    case noInternetConnection
    case requestTimedOut
    case requestNotFound
    case unknowError
    case authenticationRequired
    case internalServerError
    case badRequest
    
    case systemError
    
    case apiError_INTERNAL_ERROR
    case apiError_UNAUTHORIZED_ACCESS
    case apiError_INVALID_USER_TOKEN
    case apiError_INVALID_REQUEST
    case apiError_MAINTAINING
    
    case apiError_SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS
    case apiError_SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS
    
    case apiError_SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED
    case apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET
    case apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD
    
    case apiError_SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS
    case apiError_SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS
    case apiError_TRANSACTION_ADDRESS_STATUS_PENDING
    case apiError_TRANSACTION_ERROR_NONCE_TOO_LOW
    case apiError_TRANSACTION_ERROR_SEND_TX
    case apiError_TRANSACTION_ERROR_INVALID_ADDRESS
    
    case apiError_SOLOMON_FATAL_USER_NO_PROFILE
    
    case apiError_STORE_UNREGISTERED
    case apiError_STORE_RETAILER_UNAUTHORIZED_ACCESS
    case apiError_STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS
    case apiError_STORE_RETAILER_SALE_PERSON_PHONE_NUMBER_ADDED_BEFORE
    case apiError_USER_DEACTIVATED
    
    case apiError_STORE_RETAILER_BEACON_UNAUTHORIZED_ACCESS
    case apiError_STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT
    case apiError_STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE
    
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT
    case apiError_STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY
    
    case apiError_STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT
    case apiError_STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE
    
    case apiError_STORE_ERROR_INPUT_DTO
    case apiError_STORE_ADDRESS_STATUS_PENDING
    case apiError_STORE_ADDRESS_SIGN_TRANSACTION_STATUS_PENDING
    case apiError_STORE_TXHASH_NOT_EXIST
    case apiError_STORE_PRIVATE_BLOCK_CHAIN_ERROR
    
    case apiError_STORE_RETAILER_AIR_DROP_NOT_EXIST_ERROR
    case apiError_STORE_RETAILER_NOT_USER_CREATE_EVENT_ERROR
    case apiError_STORE_RETAILER_EVENT_STATUS_NOT_WITH_DRAW_ERROR
    case apiError_STORE_RETAILER_EVENT_TOTAL_NOT_MOZO_ERROR
    case apiError_STORE_GET_NONCE_ERROR
    case apiError_STORE_CALL_TRANSACTION_SERVICE_ERROR
    case apiError_STORE_SIGN_TRANSACTION_ERROR
    
    case apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_ONCHAIN_SAME_OFFCHAIN_FIELD
    
    case apiError_STORE_USER_ALREADY_INSTALL_APP_ERROR
    
    public var isApiError: Bool {
        switch self {
        case .network,
             .noInternetConnection,
             .requestTimedOut,
             .requestNotFound,
             .unknowError,
             .authenticationRequired,
             .internalServerError,
             .badRequest,
             .systemError:
            return false
        default:
            return true
        }
    }
    
    public var apiError: ErrorApiResponse? {
        switch self {
        case .apiError_INTERNAL_ERROR: return .INTERNAL_ERROR
        case .apiError_UNAUTHORIZED_ACCESS: return .UNAUTHORIZED_ACCESS
        case .apiError_INVALID_USER_TOKEN: return .INVALID_USER_TOKEN
        case .apiError_INVALID_REQUEST: return .INVALID_REQUEST
        case .apiError_MAINTAINING: return .MAINTAINING
            
        case .apiError_SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS:
            return .SOLOMON_USER_ADDRESS_BOOK_DUPLICATE_OFFCHAIN_ADDRESS
        case .apiError_SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS: return .SOLOMON_PAYMENT_REQUEST_INVALID_NON_EXIST_WALLET_ADDRESS
            
        case .apiError_SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED:
            return .SOLOMON_USER_PROFILE_WALLET_ADDRESS_IN_USED
        case .apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET:
            return .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_EXISTING_WALLET_ADDRESS
        case .apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD:
            return .SOLOMON_USER_PROFILE_WALLET_INVALID_UPDATE_MISSING_FIELD
        
        case .apiError_SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS:
            return .SOLOMON_SOLO_RESOURCE_FATAL_USER_NO_OFFCHAIN_ADDRESS
        case .apiError_SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS:
            return .SOLOMON_FATAL_USE_DIFFERENT_OFFCHAIN_ADDRESS
        case .apiError_TRANSACTION_ADDRESS_STATUS_PENDING:
            return .TRANSACTION_ADDRESS_STATUS_PENDING
        case .apiError_TRANSACTION_ERROR_NONCE_TOO_LOW:
            return .TRANSACTION_ERROR_NONCE_TOO_LOW
        case .apiError_TRANSACTION_ERROR_SEND_TX:
            return .TRANSACTION_ERROR_SEND_TX
        case .apiError_TRANSACTION_ERROR_INVALID_ADDRESS:
            return .TRANSACTION_ERROR_INVALID_ADDRESS
            
        case .apiError_SOLOMON_FATAL_USER_NO_PROFILE: return .SOLOMON_FATAL_USER_NO_PROFILE
        
        case .apiError_STORE_UNREGISTERED: return .STORE_UNREGISTERED
        case .apiError_STORE_RETAILER_UNAUTHORIZED_ACCESS: return .STORE_RETAILER_UNAUTHORIZED_ACCESS
        case .apiError_STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS: return .STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS
        case .apiError_STORE_RETAILER_SALE_PERSON_PHONE_NUMBER_ADDED_BEFORE: return .STORE_RETAILER_SALE_PERSON_PHONE_NUMBER_ADDED_BEFORE
        case .apiError_USER_DEACTIVATED: return .USER_DEACTIVATED
            
        case .apiError_STORE_RETAILER_BEACON_UNAUTHORIZED_ACCESS: return .STORE_RETAILER_EDIT_STORE_INFO_UNAUTHORIZED_ACCESS
        case .apiError_STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT: return .STORE_RETAILER_BEACON_INVALID_MAC_ADDRESS_FORMAT
        case .apiError_STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE: return .STORE_RETAILER_BEACON_ALREADY_REGISTERED_BEFORE
            
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST: return .STORE_RETAILER_AIR_DROP_INVALID_FROM_PERIOD_IN_THE_PAST
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD: return .STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_PERIOD
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY: return .STORE_RETAILER_AIR_DROP_INVALID_FROM_HOUR_OF_DAY
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY: return .STORE_RETAILER_AIR_DROP_INVALID_TO_HOUR_OF_DAY
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY: return .STORE_RETAILER_AIR_DROP_INVALID_FROM_GREATER_THAN_OR_EQUAL_TO_HOUR_OF_DAY
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT: return .STORE_RETAILER_AIR_DROP_INVALID_TOTAL_AMOUNT
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT: return .STORE_RETAILER_AIR_DROP_INVALID_PER_CUSTOMER_AMOUNT
        case .apiError_STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY: return .STORE_RETAILER_AIR_DROP_INVALID_TOO_LOW_FREQUENCY
            
        case .apiError_STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT: return .STORE_SHOPPER_FAVORITE_STORE_INVALID_INPUT
        case .apiError_STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE: return .STORE_SHOPPER_FAVORITE_STORE_EXISTING_FAVORITE_STORE
            
        case .apiError_STORE_ERROR_INPUT_DTO: return .STORE_ERROR_INPUT_DTO
        case .apiError_STORE_ADDRESS_STATUS_PENDING: return .STORE_ADDRESS_STATUS_PENDING
        case .apiError_STORE_ADDRESS_SIGN_TRANSACTION_STATUS_PENDING: return .STORE_ADDRESS_SIGN_TRANSACTION_STATUS_PENDING
        case .apiError_STORE_TXHASH_NOT_EXIST: return .STORE_TXHASH_NOT_EXIST
        case .apiError_STORE_PRIVATE_BLOCK_CHAIN_ERROR: return .STORE_PRIVATE_BLOCK_CHAIN_ERROR
        
        case .apiError_STORE_RETAILER_AIR_DROP_NOT_EXIST_ERROR: return .STORE_RETAILER_AIR_DROP_NOT_EXIST_ERROR
        case .apiError_STORE_RETAILER_NOT_USER_CREATE_EVENT_ERROR: return .STORE_RETAILER_NOT_USER_CREATE_EVENT_ERROR
        case .apiError_STORE_RETAILER_EVENT_STATUS_NOT_WITH_DRAW_ERROR: return .STORE_RETAILER_EVENT_STATUS_NOT_WITH_DRAW_ERROR
        case .apiError_STORE_RETAILER_EVENT_TOTAL_NOT_MOZO_ERROR: return .STORE_RETAILER_EVENT_TOTAL_NOT_MOZO_ERROR
        case .apiError_STORE_GET_NONCE_ERROR: return .STORE_GET_NONCE_ERROR
        case .apiError_STORE_CALL_TRANSACTION_SERVICE_ERROR: return .STORE_CALL_TRANSACTION_SERVICE_ERROR
        case .apiError_STORE_SIGN_TRANSACTION_ERROR: return .STORE_SIGN_TRANSACTION_ERROR
        
        case .apiError_SOLOMON_USER_PROFILE_WALLET_INVALID_ONCHAIN_SAME_OFFCHAIN_FIELD: return .SOLOMON_USER_PROFILE_WALLET_INVALID_ONCHAIN_SAME_OFFCHAIN_FIELD
        
        case .apiError_STORE_USER_ALREADY_INSTALL_APP_ERROR:
            return .STORE_USER_ALREADY_INSTALL_APP_ERROR
        default:
            return nil
        }
    }
}

extension ConnectionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network:
            return "Network error"
        case .noInternetConnection:
            return "No Internet Connection"
        case .requestTimedOut:
            return "The request timed out"
        case .requestNotFound:
            return "404 Not Found"
        case .unknowError:
            return "Unknown error"
        case .authenticationRequired:
            return "Authentication Required"
        case .internalServerError:
            return "Internal Server error"
        case .badRequest:
            return "Bad request"
        case .systemError:
            return "System error"
        default:
            return "Api Error"
        }
    }
}

extension ConnectionError : Equatable {
    public static func == (leftSide: ConnectionError, rightSide: ConnectionError) -> Bool {
        return leftSide.errorDescription == rightSide.errorDescription
    }
}

public enum SystemError: Error {
    case incorrectURL
    case incorrectCodeExchangeRequest
    case noAuthen
}

extension SystemError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incorrectURL:
            return "Incorrect URL"
        case .incorrectCodeExchangeRequest:
            return "Incorrect Code Exchange Request"
        case .noAuthen:
            return "User is an anonymous user."
        }
    }
}
