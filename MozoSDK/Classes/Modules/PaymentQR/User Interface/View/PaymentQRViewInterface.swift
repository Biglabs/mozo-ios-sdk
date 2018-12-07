//
//  PaymentQRViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
protocol PaymentQRViewInterface {
    func updateUserInterfaceWithAddress(_ address: String)
    func displayError(_ error: String)
    func updateInterfaceWithDisplayItem(_ displayItem: AddressBookDisplayItem)
    
    func displaySpinner()
    func removeSpinner()
    func displaySuccess()
}
