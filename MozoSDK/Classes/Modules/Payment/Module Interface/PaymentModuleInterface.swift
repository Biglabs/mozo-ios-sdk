//
//  PaymentModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
protocol PaymentModuleInterface {
    func selectPaymentRequestOnUI(_ item: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO)
    func updateDisplayData(page: Int)
    
    func openScanner(tokenInfo: TokenInfoDTO)
    func createPaymentRequest(_ amount: String, tokenInfo: TokenInfoDTO)
    
    func deletePaymentRequest(_ request: PaymentRequestDisplayItem)
}
