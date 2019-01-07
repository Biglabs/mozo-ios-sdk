//
//  PaymentViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
protocol PaymentViewInterface {
    func displaySpinner()
    func removeSpinner()
    func displayError(_ error: String)
    func displayTryAgain(_ error: ConnectionError)
    
    func showPaymentRequestCollection(_ collection: PaymentRequestDisplayCollection, forPage: Int)
    
    func updateUserInterfaceWithTokenInfo(_ tokenInfo: TokenInfoDTO)
}
