//
//  PaymentRequestDisplayCollection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
public class PaymentRequestDisplayCollection {
    var displayItems : [PaymentRequestDisplayItem]
    
    init(items: [PaymentRequestDTO]) {
        displayItems = []
        for item in items {
            let displayItem = displayItemForPaymentRequestDTO(item)
            displayItems.append(displayItem)
        }
        if displayItems.count == 0 {
            displayItems = testItems()
        }
    }
    
    func testItems() -> [PaymentRequestDisplayItem] {
        let date = self.formattedDateTime(Int64(Date().timeIntervalSince1970))
        let nameAddress1 = DisplayUtils.buildNameFromAddress(address: "0x011df24265841dcdbf2e60984bb94007b0c1d76a")
        let item1 = PaymentRequestDisplayItem(date: date, amount: 5000, displayNameAddress: nameAddress1, requestingAddress: "0x011df24265841dcdbf2e60984bb94007b0c1d76a")
        let nameAddress2 = DisplayUtils.buildNameFromAddress(address: "0x06B094DFcBd65F735e0bF0318384697CC0EB82f7")
        let item2 = PaymentRequestDisplayItem(date: date, amount: 1141, displayNameAddress: nameAddress2, requestingAddress: "0x06B094DFcBd65F735e0bF0318384697CC0EB82f7")
        let nameAddress3 = DisplayUtils.buildNameFromAddress(address: "0x327b993ce7201a6e8b1df02256910c9ea6bc4865")
        let item3 = PaymentRequestDisplayItem(date: date, amount: 4424, displayNameAddress: nameAddress3, requestingAddress: "0x327b993ce7201a6e8b1df02256910c9ea6bc4865")
        let nameAddress4 = DisplayUtils.buildNameFromAddress(address: "0x011df24265841dcdbf2e60984bb94007b0c1d76a")
        let item4 = PaymentRequestDisplayItem(date: date, amount: 1123, displayNameAddress: nameAddress4, requestingAddress: "0x011df24265841dcdbf2e60984bb94007b0c1d76a")
        let nameAddress5 = DisplayUtils.buildNameFromAddress(address: "0xa208a321c7a08f52492db0a9eac38aaa6079d2c7")
        let item5 = PaymentRequestDisplayItem(date: date, amount: 5125, displayNameAddress: nameAddress5, requestingAddress: "0xa208a321c7a08f52492db0a9eac38aaa6079d2c7")
        let nameAddress6 = DisplayUtils.buildNameFromAddress(address: "0x06B094DFcBd65F735e0bF0318384697CC0EB82f7")
        let item6 = PaymentRequestDisplayItem(date: date, amount: 52421, displayNameAddress: nameAddress6, requestingAddress: "0x06B094DFcBd65F735e0bF0318384697CC0EB82f7")
        let nameAddress7 = DisplayUtils.buildNameFromAddress(address: "0x327b993ce7201a6e8b1df02256910c9ea6bc4865")
        let item7 = PaymentRequestDisplayItem(date: date, amount: 52421, displayNameAddress: nameAddress7, requestingAddress: "0x327b993ce7201a6e8b1df02256910c9ea6bc4865")
        return [item1, item2, item3, item4, item5, item6, item7]
    }
    
    func appendCollection(_ collection: PaymentRequestDisplayCollection) {
        displayItems = displayItems + collection.displayItems
    }
    
    func displayItemForPaymentRequestDTO(_ request: PaymentRequestDTO) -> PaymentRequestDisplayItem {
        let date = self.formattedDateTime(request.date ?? 0)
        let amount = (request.amount?.convertOutputValue(decimal: Int(request.decimal ?? 0)))!
        let displayNameAddress = DisplayUtils.buildNameFromAddress(address: request.requestingAddress ?? "")
        return PaymentRequestDisplayItem(date: date, amount: amount, displayNameAddress: displayNameAddress, requestingAddress: request.requestingAddress ?? "")
    }
    
    func formattedDateTime(_ dateTime: Int64) -> String {
        let timeFormat = "HH:mm a"
        let timeText = DisplayUtils.convertInt64ToStringWithFormat(dateTime, format: timeFormat)
        let dateFormat = "MMM dd, yyyy"
        let dateText = DisplayUtils.convertInt64ToStringWithFormat(dateTime, format: dateFormat)
        return "\(timeText) \(dateText)"
    }
}
