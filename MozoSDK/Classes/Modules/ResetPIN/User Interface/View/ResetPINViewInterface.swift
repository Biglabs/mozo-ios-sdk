//
//  ResetPINViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/8/19.
//

import Foundation
protocol ResetPINViewInterface {
    func allowGoNext()
    func disallowGoNext()
    func mnemonicsNotBelongToUserWallet()
    
    func displayWaiting(isChecking: Bool)
    func closeWaiting(clearData: Bool, displayTryAgain: Bool)
}
