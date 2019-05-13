//
//  MnemonicsInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/10/19.
//

import Foundation
protocol ResetPINInteractorInput {
    func validateMnemonics(_ mnemonics: String)
    func validateMnemonicsForRestore(_ mnemonics: String)
    
    func manageResetPINForWallet(_ mnemonics: String, pin: String)
}
protocol ResetPINInteractorOutput {
    func allowGoNext()
    func disallowGoNext()
    func validateFailedForRestore()
    func mnemonicsNotBelongToUserWallet()
    
    func requestEnterNewPIN(mnemonics: String)
    
    func manageResetFailedWithError(_ error: ConnectionError)
    func resetPINSuccess()
}
