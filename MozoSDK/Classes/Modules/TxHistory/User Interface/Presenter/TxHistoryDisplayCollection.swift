//
//  TxHistoryDisplayCollection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/3/18.
//

import Foundation

public class TxHistoryDisplayCollection {
    public var displayItems : [TxHistoryDisplayItem]
    
    init(items: [TxHistoryDTO]) {
        displayItems = []
        for item in items {
            // Filter transaction success
            if item.txStatus != TransactionStatusType.FAILED.rawValue {
                let displayItem = displayItemForTxHistoryDTO(item)
                displayItems.append(displayItem)
            }
        }
    }
    
    public func appendCollection(_ collection: TxHistoryDisplayCollection) {
        displayItems = displayItems + collection.displayItems
    }
    
    func displayItemForTxHistoryDTO(_ txHistory: TxHistoryDTO) -> TxHistoryDisplayItem {
        var action = self.buildAction(addressFrom: txHistory.addressFrom!)
        // With top up transaction, action will be created by TopUpReasonEnum(rawValue: txHistory.topUpReason)
        let topUpReasonEnum = TopUpReasonEnum(rawValue: txHistory.topUpReason ?? "")
        if let topUpReasonEnum = topUpReasonEnum {
            action = topUpReasonEnum.displayText
        }
        let date = self.formattedDateTime(txHistory.time ?? 0)
        let amount = (txHistory.amount?.convertOutputValue(decimal: Int(txHistory.decimal ?? 0)))!
        let exAmount = self.calculateExchangeValue(amount)
        let fromNameWithDate = NSAttributedString()
            //self.buildFromNameWithDate(addressFrom: txHistory.addressFrom ?? "", addressTo: txHistory.addressTo ?? "", action: action, date: date, topUpReason: topUpReasonEnum)
        let name = self.buildName(addressFrom: txHistory.addressFrom ?? "", addressTo: txHistory.addressTo ?? "", action: action, topUpReason: topUpReasonEnum)
        let nameOrAddress = self.buildDisplayNameOrAddress(addressFrom: txHistory.addressFrom ?? "", addressTo: txHistory.addressTo ?? "", action: action, name: name)
        let fromtoText = self.buildFromTo(addressFrom: txHistory.addressFrom ?? "", addressTo: txHistory.addressTo ?? "", action: action, topUpReason: topUpReasonEnum)
        return TxHistoryDisplayItem(action: action, date: date, fromNameWithDate: fromNameWithDate, amount: amount, exAmount: exAmount, txStatus: txHistory.txStatus ?? "", addressFrom: txHistory.addressFrom, addressTo: txHistory.addressTo, topUpReason: topUpReasonEnum, nameOrAddress: nameOrAddress, fromtoText: fromtoText, name: name)
    }
    
    func buildAction(addressFrom: String) -> String {
        let currentAddress = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.offchainAddress
        var action = TransactionType.Received.value
        if addressFrom.lowercased() == currentAddress?.lowercased() {
            action = TransactionType.Sent.value
        }
        return action
    }
    
    func formattedDateTime(_ dateTime: Int64) -> String {
        if dateTime == 0 {
            return "Just now".localized
        }
        let format = "HH:mm MMM d, yyyy".localized
        return DisplayUtils.convertInt64ToStringWithFormat(dateTime, format: format)
    }
    
    func buildName(addressFrom: String, addressTo: String, action: String, topUpReason: TopUpReasonEnum?) -> String {
        var address = action == TransactionType.Received.value ? addressFrom : addressTo
        if let topUpReason = topUpReason {
            if topUpReason == .TOP_UP_ADD_MORE {
                address = addressFrom
            } else {
                address = addressTo
            }
        }
        var displayName = ""
        if !address.isEmpty {
            let list = SafetyDataManager.shared.addressBookList
            if let ab = AddressBookDTO.addressBookFromAddress(address, array: list), let name = ab.name {
                displayName = name
            } else {
                let storeList = SafetyDataManager.shared.storeBookList
                if let ab = StoreBookDTO.storeBookFromAddress(address, array: storeList), let name = ab.name {
                    displayName = name
                }
            }
        }
        
        return displayName
    }
    
    func buildDisplayNameOrAddress(addressFrom: String, addressTo: String, action: String, name: String) -> String {
        let address = action == TransactionType.Received.value ? addressFrom : addressTo
        return name.isEmpty ? address : name
    }
    
    func buildFromTo(addressFrom: String, addressTo: String, action: String, topUpReason: TopUpReasonEnum?) -> String {
        var fromtoText = action == TransactionType.Received.value ? "From" : "To"
        if let topUpReason = topUpReason {
            switch topUpReason {
            case .TOP_UP_ADD_MORE:
                fromtoText = "From"
            case .TOP_UP_WITHDRAW:
                fromtoText = "To"
            default:
                fromtoText = ""
            }
        }
        return fromtoText.localized
    }
    
    func buildFromNameWithDate(addressFrom: String, addressTo: String, action: String, date: String, topUpReason: TopUpReasonEnum?) -> NSAttributedString {
        var address = action == TransactionType.Received.value ? addressFrom : addressTo
        if let topUpReason = topUpReason {
            if topUpReason == .TOP_UP_ADD_MORE {
                address = addressFrom
            } else {
                address = addressTo
            }
        }
        var displayName = ""
        if !address.isEmpty {
            let list = SafetyDataManager.shared.addressBookList
            if let ab = AddressBookDTO.addressBookFromAddress(address, array: list), let name = ab.name {
                displayName = name
            } else {
                let storeList = SafetyDataManager.shared.storeBookList
                if let ab = StoreBookDTO.storeBookFromAddress(address, array: storeList), let name = ab.name {
                    displayName = name
                }
            }
        }
        var lStrLabelText: NSMutableAttributedString
        if displayName.isEmpty {
            let finalStr = NSAttributedString(string: date)
            lStrLabelText = NSMutableAttributedString(attributedString: finalStr)
        } else {
            let prefix = (action == TransactionType.Received.value ? "From" : "To").localized
            var fromNameWithDate = "\(prefix) \(displayName) - \(date)"
            if let topUpReason = topUpReason {
                switch topUpReason {
                case .TOP_UP_ADD_MORE:
                    fromNameWithDate = "\("From".localized) \(displayName) - \(date)"
                case .TOP_UP_WITHDRAW:
                    fromNameWithDate = "\("To".localized) \(displayName) - \(date)"
                default:
                    fromNameWithDate = "\(displayName) - \(date)"
                }
            }
            let finalStr = NSAttributedString(string: fromNameWithDate)
            lStrLabelText = NSMutableAttributedString(attributedString: finalStr)
            let descriptor = UIFont.boldSystemFont(ofSize: 11).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
            let font : UIFont = UIFont.init(descriptor: descriptor!, size: 11)
            
            let string = NSString(string: fromNameWithDate)
            let range = string.range(of: displayName)
            lStrLabelText.addAttribute(.font, value: font, range: range)
            lStrLabelText.addAttribute(.foregroundColor, value: ThemeManager.shared.textSection, range: range)
        }
        
        return lStrLabelText
    }
    
    func calculateExchangeValue(_ value: Double) -> Double {
        var result = 0.0
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            let type = CurrencyType(rawValue: rateInfo.currency?.uppercased() ?? "")
            if let type = type, let rateValue = rateInfo.rate {
                result = (value * rateValue).rounded(toPlaces: type.decimalRound)
                if type == .VND {
                    result = ((value * rateValue) / 1000).rounded() * 1000
                }
            }
        }
        return result
    }
}
