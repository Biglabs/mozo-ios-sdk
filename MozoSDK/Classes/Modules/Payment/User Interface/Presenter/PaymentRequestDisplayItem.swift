//
//  PaymentRequestDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation

struct PaymentRequestDisplayItem {
    let id: Int64
    let date: String
    let amount: NSNumber
    var displayNameAddress: String
    let requestingAddress: String
    
    init(id: Int64, date: String, amount: NSNumber, displayNameAddress: String, requestingAddress: String) {
        self.id = id
        self.date = date
        self.amount = amount
        self.displayNameAddress = displayNameAddress
        self.requestingAddress = requestingAddress
    }
    
    init(scheme: String){
        let url = URL(string: scheme)
        let address = String(scheme.split(separator: "?")[0].split(separator: ":")[1])
        let amnt = url?.queryParameters?["amount"]
        self.date = ""
        self.amount = NSDecimalNumber(string: amnt ?? "0")
        self.displayNameAddress = ""
        self.requestingAddress = address
        self.id = 0
    }
    
    init(scheme: String, date: String, id: Int64){
        let url = URL(string: scheme)
        let address = String(scheme.split(separator: "?")[0].split(separator: ":")[1])
        let amnt = url?.queryParameters?["amount"]
        self.date = date
        self.amount = NSDecimalNumber(string: amnt ?? "0")
        self.displayNameAddress = ""
        self.requestingAddress = address
        self.id = id
    }
    
    func toScheme() -> String {
        return "mozox:\(self.requestingAddress)?amount=\(self.amount)"
    }
}
