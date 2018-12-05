//
//  PaymentModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
protocol PaymentModuleDelegate {
    func didChoosePaymentRequest(_ paymentItem: PaymentRequestDisplayItem)
}
