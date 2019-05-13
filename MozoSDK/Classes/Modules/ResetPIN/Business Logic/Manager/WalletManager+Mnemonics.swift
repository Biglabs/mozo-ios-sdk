//
//  WalletManager+Mnemonics.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/8/19.
//

import Foundation
import web3swift

extension WalletManager {
    func validateMnemonicsString(withString mnemonics: String) -> Bool {
        let words = mnemonics.components(separatedBy: " ")
        if words.count == 12 {
            return validateMnemonics(withWords: words)
        }
        return false
    }
    
    func validateMnemonics(withWords words: [String]) -> Bool {
        guard let _ = BIP39.mnemonicsToEntropy(words.joined(separator: " ")) else { return false }
        return true
    }
}
