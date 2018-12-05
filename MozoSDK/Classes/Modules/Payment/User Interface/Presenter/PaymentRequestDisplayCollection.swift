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
    }
    
    func appendCollection(_ collection: PaymentRequestDisplayCollection) {
        displayItems = displayItems + collection.displayItems
    }
    
    func displayItemForPaymentRequestDTO(_ request: PaymentRequestDTO) -> PaymentRequestDisplayItem {
        let date = self.formattedDateTime(request.date ?? 0)
        let amount = (request.amount?.convertOutputValue(decimal: Int(request.decimal ?? 0)))!
        return PaymentRequestDisplayItem(date: date, amount: amount, requestingAddress: request.requestingAddress ?? "")
    }
    
    func formattedDateTime(_ dateTime: Int64) -> String {
        let timeFormat = "HH:mm a"
        let timeText = DisplayUtils.convertInt64ToStringWithFormat(dateTime, format: timeFormat)
        let dateFormat = "MMM dd, yyyy"
        let dateText = DisplayUtils.convertInt64ToStringWithFormat(dateTime, format: dateFormat)
        return "\(timeText) \(dateText)"
    }
}
