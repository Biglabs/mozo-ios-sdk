//
//  PaymentModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
protocol PaymentModuleInterface {
    func loadTokenInfo()
    func selectPaymentRequestOnUI(_ item: PaymentRequestDisplayItem)
    func updateDisplayData(page: Int)
    
    func openScanner()
    func createPaymentRequest(_ amount: Double)
}
