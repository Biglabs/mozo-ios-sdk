//
//  PaymentQRModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
protocol PaymentQRModuleInterface {
    func showAddressBookInterface()
    func showScanQRCodeInterface()
    func sendPaymentRequest(_ displayItem: PaymentRequestDisplayItem, toAddress: String)
    func close()
    
    func findContact(_ phoneNo: String)
}
