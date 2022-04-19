//
//  WalletInteractor+Auto.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
extension WalletInteractor {
    func updateWalletsToUserProfileInAutoMode(isCreateNew: Bool, mnemonics: String, rawPin: String, wallets: [WalletModel]) {
        print("WalletInteractor - Update wallet to user profile in auto mode")
        if isCreateNew {
            let offchainWallet = wallets[0]
            let offchainAddress = offchainWallet.address
            let onchainWallet = wallets[1]
            let onchainAddress = onchainWallet.address
            
            let encryptedSeedPhrase = mnemonics.encrypt(key: rawPin)
            if let pin_secret = AccessTokenManager.getPinSecret() {
                let encryptedPin = rawPin.encrypt(key: pin_secret)
                let updatingWalletInfo = WalletInfoDTO(encryptSeedPhrase: encryptedSeedPhrase, offchainAddress: offchainAddress, onchainAddress: onchainAddress, encryptedPin: encryptedPin)
                // Must waiting for processing invitation
                if SafetyDataManager.shared.checkProcessingInvitation == false {
                    self.updateFullWalletInfoInAutoMode(updatingWalletInfo, wallets: wallets)
                } else {
                    self.setupTimerWaitingInvitation(updatingWalletInfo: updatingWalletInfo, wallets: wallets)
                }
            } else {
                self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
            }
        } else {
            self.updateWalletsForCurrentUser(wallets)
            self.autoOutput?.manageWalletAutoSuccessfully()
        }
    }
    
    func updateFullWalletInfoInAutoMode(_ walletInfo: WalletInfoDTO, wallets: [WalletModel]) {
        print("WalletInteractor - Update full wallet info in auto mode")
        _ = self.apiManager.updateWallets(walletInfo: walletInfo)
            .done { uProfile -> Void in
                let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                SessionStoreManager.saveCurrentUser(user: userDto)
                print("WalletInteractor - Update Wallet To User Profile result: [\(uProfile)]")
                self.updateWalletsForCurrentUser(wallets)
                self.autoOutput?.manageWalletAutoSuccessfully()
            }.catch({ (error) in
                self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: error as? ConnectionError ?? .systemError, showTryAgain: true)
            })
    }
    
    func manageWalletInAutoMode(isCreateNew: Bool, mnemonics: String, rawPin: String) {
        var wallets = self.walletManager.createNewWallets(mnemonics: mnemonics)
        // Handle wallets empty
        if wallets.count < 2 {
            self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
            return
        }
        for i in 0..<wallets.count {
            wallets[i].privateKey = wallets[i].privateKey.encrypt(key: rawPin)
        }
        let encryptedSeedPhrase = mnemonics.encrypt(key: rawPin)
        _ = updateMnemonicAndPinForCurrentUser(mnemonic: encryptedSeedPhrase, pin: rawPin).done { (result) in
            self.updateWalletsToUserProfileInAutoMode(isCreateNew: isCreateNew, mnemonics: mnemonics, rawPin: rawPin, wallets: wallets)
        }.catch({ (error) in
            self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
        })
    }
}
extension WalletInteractor: WalletInteractorAutoInput {
    func createMnemonicAndPinAutomatically() {
        if let mnemonics = walletManager.generateMnemonics() {
            let randomPIN = [String(Int.random(in: 0...9)), String(Int.random(in: 0...9)), String(Int.random(in: 0...9)),
                             String(Int.random(in: 0...9)), String(Int.random(in: 0...9)), String(Int.random(in: 0...9))].joined()
            manageWalletInAutoMode(isCreateNew: true, mnemonics: mnemonics, rawPin: randomPIN)
        } else {
            self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
        }
    }
    
    func recoverWalletsAutomatically() {
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
            let encryptedSeedPhrase = wallet.encryptSeedPhrase,
            let encryptedPin = wallet.encryptedPin,
            let pin_secret = AccessTokenManager.getPinSecret(){
                let decryptPin = encryptedPin.decrypt(key: pin_secret)
                let mnemonics = encryptedSeedPhrase.decrypt(key: decryptPin)
                manageWalletInAutoMode(isCreateNew: false, mnemonics: mnemonics, rawPin: decryptPin)
        } else {
            self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
        }
    }
}
