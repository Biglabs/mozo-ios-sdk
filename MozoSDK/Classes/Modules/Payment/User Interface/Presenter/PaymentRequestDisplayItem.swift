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
    let amount: Double
    var displayNameAddress: String
    let requestingAddress: String
    
    init(id: Int64, date: String, amount: Double, displayNameAddress: String, requestingAddress: String) {
        self.id = id
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
        self.id = 0
    }
    
    init(scheme: String, date: String, id: Int64){
        let url = URL(string: scheme)
        let address = String(scheme.split(separator: "?")[0].split(separator: ":")[1])
        let amnt = url?.queryParameters?["amount"]
        self.date = date
        self.amount = Double(amnt ?? "0") ?? 0
        self.displayNameAddress = ""
        self.requestingAddress = address
        self.id = id
    }
    
    func toScheme() -> String {
        return "mozox:\(self.requestingAddress)?amount=\(self.amount)"
    }
}
