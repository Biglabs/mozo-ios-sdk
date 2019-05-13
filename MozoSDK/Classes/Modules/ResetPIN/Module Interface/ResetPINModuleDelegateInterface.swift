//
//  ResetPINModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/10/19.
//

import Foundation
protocol ResetPINModuleDelegate {
    func manageWalletWithMnemonics(mnemonics: String, pin: String)
}
