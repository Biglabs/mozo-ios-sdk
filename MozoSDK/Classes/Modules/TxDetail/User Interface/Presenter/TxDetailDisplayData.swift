//
//  TxDetailDisplayData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/3/18.
//

import Foundation

class TxDetailDisplayData {
    var tokenInfo: TokenInfoDTO?
    var transaction: IntermediaryTransactionDTO?
    var rawTx: TransactionDTO?
    var txHistory: TxHistoryDisplayItem?
    var balanceNotification: BalanceNotification?
    
    init(transaction: IntermediaryTransactionDTO, tokenInfo: TokenInfoDTO) {
        self.transaction = transaction
        self.tokenInfo = tokenInfo
    }
    
    init(transaction: TransactionDTO, tokenInfo: TokenInfoDTO) {
        
    }
    
    init(txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO) {
        self.txHistory = txHistory
        self.tokenInfo = tokenInfo
    }
    
    init(notify: BalanceNotification, tokenInfo: TokenInfoDTO) {
        self.balanceNotification = notify
        self.tokenInfo = tokenInfo
    }
    
    func collectDisplayItem() -> TxDetailDisplayItem {
        if transaction != nil {
            return buildDisplayItemFromTransaction()
        }
        return buildDisplayItemFromHistory()
    }
    
    func buildDisplayItemFromRawTransaction() -> TxDetailDisplayItem {
        let amount = rawTx?.outputs![0].value ?? 0
        let addressFrom = rawTx?.inputs![0].addresses![0] ?? ""
        let addressTo = rawTx?.outputs![0].addresses![0] ?? ""
        let decimal = tokenInfo?.decimals ?? 0
        let dateTime = Date()
        
        let balance = tokenInfo?.balance ?? 0.0
        let currentBalance = balance.convertOutputValue(decimal: decimal)
        let currentAddress = tokenInfo?.address ?? ""
        
        let action = buildAction(addressFrom: addressFrom, currentAddress: currentAddress)
        let cvAmount = amount.convertOutputValue(decimal: decimal)
        let cvDate = buildDateString(dateTime)
        let exAmount = calculateExchangeValue(cvAmount)
        let exCurrentBalance = calculateExchangeValue(currentBalance)
        
        let displayItem = TxDetailDisplayItem(action: action, addressFrom: addressFrom, addressTo: addressTo, amount: cvAmount, exAmount: exAmount, dateTime: cvDate, fees: 0, symbol: nil, hash: rawTx?.hash ?? "", currentBalance: currentBalance, exCurrentBalance: exCurrentBalance, currentAddress: currentAddress)
        return displayItem
    }
    
    func buildDisplayItemFromTransaction() -> TxDetailDisplayItem {
        let amount = transaction?.tx?.outputs![0].value ?? 0
        let addressFrom = transaction?.tx?.inputs![0].addresses![0] ?? ""
        let addressTo = transaction?.tx?.outputs![0].addresses![0] ?? ""
        let decimal = tokenInfo?.decimals ?? 0
        let dateTime = Date()
        
        let balance = tokenInfo?.balance ?? 0.0
        let currentBalance = balance.convertOutputValue(decimal: decimal)
        let currentAddress = tokenInfo?.address ?? ""
        
        let action = buildAction(addressFrom: addressFrom, currentAddress: currentAddress)
        let cvAmount = amount.convertOutputValue(decimal: decimal)
        let cvDate = buildDateString(dateTime)
        let exAmount = calculateExchangeValue(cvAmount)
        let exCurrentBalance = calculateExchangeValue(currentBalance)
        
        let displayItem = TxDetailDisplayItem(action: action, addressFrom: addressFrom, addressTo: addressTo, amount: cvAmount, exAmount: exAmount, dateTime: cvDate, fees: 0, symbol: nil, hash: transaction?.tx?.hash ?? "", currentBalance: currentBalance, exCurrentBalance: exCurrentBalance, currentAddress: currentAddress)
        return displayItem
    }
    
    func buildHistoryDisplayItem(_ time: Int64? = nil) -> TxHistoryDisplayItem {
        let decimal = tokenInfo?.decimals ?? 0
        var dateTime = Date()
        if let t = time, t > 0 {
            dateTime = Date(timeIntervalSince1970: Double(t / 1000))
        }
        let currentAddress = tokenInfo?.address ?? ""
        
        let amount = (balanceNotification?.amount ?? 0).convertOutputValue(decimal: decimal)
        return TxHistoryDisplayItem(
            action: buildAction(addressFrom: balanceNotification?.from ?? "", currentAddress: currentAddress),
            date: buildDateString(dateTime),
            fromNameWithDate: NSAttributedString(),
            amount: amount,
            exAmount: calculateExchangeValue(amount),
            txStatus: "",
            addressFrom: balanceNotification?.from,
            addressTo: balanceNotification?.to,
            topUpReason: nil,
            nameOrAddress: "",
            fromtoText: "",
            name: ""
        )
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
    
    func buildDisplayItemFromHistory() -> TxDetailDisplayItem {
        let balance = tokenInfo?.balance ?? 0.0
        let currentAddress = tokenInfo?.address ?? ""
        let currentBalance = balance.convertOutputValue(decimal: tokenInfo?.decimals ?? 0)
        let amount = txHistory?.amount ?? 0
        let exAmount = calculateExchangeValue(amount)
        let exCurrentBalance = calculateExchangeValue(currentBalance)
        
        let displayItem = TxDetailDisplayItem(action: txHistory?.action ?? "", addressFrom: txHistory?.addressFrom ?? "", addressTo: txHistory?.addressTo ?? "", amount: amount, exAmount: exAmount, dateTime: txHistory?.date ?? "", fees: 0, symbol: nil, hash: transaction?.tx?.hash ?? "", currentBalance: currentBalance, exCurrentBalance: exCurrentBalance, currentAddress: currentAddress)
        return displayItem
    }
    
    func buildAction(addressFrom: String, currentAddress: String) -> String {
        var action = TransactionType.Received.value
        if addressFrom.lowercased() == currentAddress.lowercased() {
            action = TransactionType.Sent.value
        }
        return action
    }
    
    func buildDateString(_ date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "HH:mm MMM d, yyyy".localized
        return dateFormatterPrint.string(from: date)
    }
}
