//
//  PaymentQRInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
protocol PaymentQRInteractorInput: ABSupportInteractorInput {
    func validateValueFromScanner(_ scanValue: String)
    func sendPaymentRequest(toAddress: String, item: PaymentRequestDisplayItem)
}
protocol PaymentQRInteractorOutput: ABSupportInteractorOutput {
    func didReceiveError(_ error: String?)
    func didSendPaymentRequestSuccess(toAddress: String, item: PaymentRequestDisplayItem)
    func errorWhileSendPayment(error: Any, toAddress: String, item: PaymentRequestDisplayItem)
    func didReceiveAddressFromScannedValue(address: String)
    func didReceiveAddressBookDisplayItem(_ item: AddressBookDisplayItem)
}
