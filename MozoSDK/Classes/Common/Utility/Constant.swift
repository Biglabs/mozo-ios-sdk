//
//  Constant.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/19/18.
//

import Foundation

public enum CoinType {
    case BTC
    case ETH
    case MOZO_ONCHAIN
    case MOZO_OFFCHAIN
    
    public var key : String {
        switch self {
            case .BTC: return "BTC"
            case .ETH: return "ETH"
            case .MOZO_ONCHAIN: return "MOZO_ONCHAIN"
            case .MOZO_OFFCHAIN: return "MOZO_OFFCHAIN"
        }
    }
    
    public var value : String {
        switch self {
            case .BTC: return "BTC"
            case .ETH: return "ETH"
            case .MOZO_ONCHAIN: return "MOZO_ONCHAIN"
            case .MOZO_OFFCHAIN: return "MOZO_OFFCHAIN"
        }
    }
    
    public var icon : String {
        switch self {
            case .BTC: return "ic_BTC"
            case .ETH: return "ic_ETH"
            case .MOZO_ONCHAIN: return "ic_MOZO"
            case .MOZO_OFFCHAIN: return "ic_MOZO_OFFCHAIN"
        }
    }
    
    public var scanName : String {
        switch self {
            case .BTC: return "bitcoin"
            case .ETH: return "ethereum"
            case .MOZO_ONCHAIN: return "mozo_onchain"
            case .MOZO_OFFCHAIN: return "mozo_offchain"
        }
    }
}

public enum Module {
    case Auth
    case Wallet
    case Transaction
    case TxHistory
    case Airdrop
    case Withdraw
    case Payment
    case AddressBook
    case Convert
    case ResetPIN
    case SpeedSelection
    case BackupWallet
    case Settings
    case ChangePIN
    case Redeem
    case TopUp
    case TopUpTransfer
    
    public var key : String {
        switch self {
            case .Auth: return "Auth"
            case .Wallet: return "Wallet"
            case .Transaction: return "Transaction"
            case .TxHistory: return "TxHistory"
            case .Airdrop: return "Airdrop"
            case .Withdraw: return "Withdraw"
            case .Payment: return "Payment"
            case .AddressBook: return "AddressBook"
            case .Convert: return "Convert"
            case .ResetPIN: return "ResetPIN"
            case .SpeedSelection: return "SpeedSelection"
            case .BackupWallet: return "BackupWallet"
            case .Settings: return "Settings"
            case .ChangePIN: return "ChangePIN"
            case .Redeem: return "Redeem"
            case .TopUp: return "TopUp"
            case .TopUpTransfer: return "TopUpTransfer"
        }
    }
    
    public var value : String {
        switch self {
            case .Auth: return "Auth"
            case .Wallet: return "Wallet"
            case .Transaction: return "Transaction"
            case .TxHistory: return "TxHistory"
            case .Airdrop: return "Airdrop"
            case .Withdraw: return "Withdraw"
            case .Payment: return "Payment"
            case .AddressBook: return "AddressBook"
            case .Convert: return "Convert"
            case .ResetPIN: return "ResetPIN"
            case .SpeedSelection: return "SpeedSelection"
            case .BackupWallet: return "BackupWallet"
            case .Settings: return "Settings"
            case .ChangePIN: return "ChangePIN"
            case .Redeem: return "Redeem"
            case .TopUp: return "TopUp"
            case .TopUpTransfer: return "TopUpTransfer"
        }
    }
}

public enum BalanceDisplayType {
    case NormalBalance
    case DetailBalance
    case Full
    case NormalAddress
    case DetailAddress

    public var id : String {
        switch self {
        case .NormalBalance: return "MozoBalanceView"
        case .DetailBalance: return "MozoBalanceDetailView"
        case .Full: return "MozoBalanceDetailQRView"
        case .NormalAddress: return "MozoAddressView"
        case .DetailAddress: return "MozoAddressDetailView"
        }
    }
    
    public var anonymousId : String {
        switch self {
        case .NormalBalance: return "MozoBalanceLoginView"
        case .DetailBalance: return "MozoAddressDetailLoginView"
        case .Full: return "MozoBalanceDetailQRLoginView"
        case .NormalAddress: return "MozoAddressLoginView"
        case .DetailAddress: return "MozoBalanceDetailQRLoginView"
        }
    }
}

public enum TransactionType {
    case All
    case Sent
    case Received
    
    public var value : String {
        switch self {
        case .Sent: return "Sent"
        case .Received: return "Received"
        default: return "All"
        }
    }
}

public enum MozoNetwork {
    case DevNet
    case TestNet
    case MainNet
    
    public var value : String {
        switch self {
        case .DevNet: return "DevNet"
        case .TestNet: return "TestNet"
        case .MainNet: return "MainNet"
        }
    }
}

public enum CurrencyType: String {
    case USD = "USD"
    case KRW = "KRW"
    case VND = "VND"
    
    public var decimalRound: Int {
        switch self {
        case .USD: return 3
        case .KRW: return 1
        case .VND: return 0
        }
    }
    
    public var unit: String {
        switch self {
        case .USD: return "$"
        case .KRW: return "₩"
        case .VND: return "đ"
        }
    }
}

public enum SymbolType {
    case SOLO
    case MOZO
    case MOZOX
    
    public var value : String {
        switch self {
        case .SOLO: return "SOLO"
        case .MOZO: return "MOZO"
        case .MOZOX: return "MOZOX"
        }
    }
}

public enum TransactionStatusType: String {
    case SUCCESS = "SUCCESS"
    case FAILED = "FAILED"
    case PENDING = "PENDING"
}

public enum MaintenanceStatusType: String {
    case MAINTAINED = "MAINTAINED"
    case HEALTHY = "HEALTHY"
}
