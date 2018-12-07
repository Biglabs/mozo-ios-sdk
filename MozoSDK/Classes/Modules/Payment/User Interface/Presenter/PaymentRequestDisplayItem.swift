//
//  PaymentRequestDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation

struct PaymentRequestDisplayItem {
    let date: String
    let amount: Double
    let displayNameAddress: String
    let requestingAddress: String
    
    init(date: String, amount: Double, displayNameAddress: String, requestingAddress: String) {
        self.date = date
        self.amount = amount
        self.displayNameAddress = displayNameAddress
        self.requestingAddress = requestingAddress
    }
    
    //    mozox:ec00a109f574e6960a12226d13b0ece38619e08c?amount=0.05
    init(scheme: String){
        let url = URL(string: scheme)
        let address = String(scheme.split(separator: "?")[0].split(separator: ":")[1])
        let amnt = url?.queryParameters?["amount"]
        self.date = ""
        self.amount = Double(amnt ?? "0") ?? 0
        self.displayNameAddress = ""
        self.requestingAddress = address
    }
    
    func toScheme() -> String {
        return "mozox:\(self.requestingAddress)?amount=\(self.amount)"
    }
}
