//
//  WalletModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/29/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation

protocol WalletModuleInterface {
    func processInitialWalletInterface()
    func cancel()
    func generateMnemonics()
    func skipShowPassPharse(passPharse : String, requestedModule: Module)
    
    func enterPIN(pin: String)
    func verifyPIN(pin: String)
    func verifyPINToRecoverFromServerEncryptedPhrase(pin: String)
    func manageWallet(passPhrase: String?, pin: String)
    func manageWalletToRecoverFromServerEncryptedPhrase(pin: String)
    func verifyConfirmPIN(pin: String, confirmPin: String)
    
    func displayResetPINInterface(requestFrom module: Module)
    
    func manageWalletForResetPIN(passPhrase: String?, pin: String)
    
    func verifyCurrentPINToChangePIN(pin: String)
    func verifyConfirmPINToChangePIN(pin: String, confirmPin: String)
    
    func verifyCurrentPINToBackup(pin: String)
}
