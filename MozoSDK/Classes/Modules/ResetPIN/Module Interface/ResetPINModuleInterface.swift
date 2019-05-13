//
//  ResetPINModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/9/19.
//

import Foundation
protocol ResetPINModuleInterface {
    func checkMnemonics(_ mnemonics: String)
    func resetPINWithMnemonics(_ mnemonics: String)
    
    func completeResetPIN()
}
