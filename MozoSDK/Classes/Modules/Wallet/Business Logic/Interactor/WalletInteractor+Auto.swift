//
//  WalletInteractor+Auto.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
extension WalletInteractor {
    func updateWalletsToUserProfileInAutoMode(isCreateNew: Bool, mnemonics: String, rawPin: String, wallets: [WalletModel]) {
        if isCreateNew {
            let offchainWallet = wallets[0]
            let offchainAddress = offchainWallet.address
            let onchainWallet = wallets[1]
            let onchainAddress = onchainWallet.address
            
            let encryptedSeedPhrase = mnemonics.encrypt(key: rawPin)
            if let pin_secret = AccessTokenManager.getPinSecret() {
                let encryptedPin = rawPin.encrypt(key: pin_secret)
                let updatingWalletInfo = WalletInfoDTO(encryptSeedPhrase: encryptedSeedPhrase, offchainAddress: offchainAddress, onchainAddress: onchainAddress, encryptedPin: encryptedPin)
                
                DispatchQueue.main.async {
                    // Must waiting for processing invitation
                    if SafetyDataManager.shared.checkProcessingInvitation == false {
                        self.updateFullWalletInfoInAutoMode(updatingWalletInfo, wallets: wallets)
                    } else {
                        self.setupTimerWaitingInvitation(updatingWalletInfo: updatingWalletInfo, wallets: wallets)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
                }
            }
        } else {
            self.updateWalletsForCurrentUser(wallets)
            DispatchQueue.main.async {
                self.autoOutput?.manageWalletAutoSuccessfully()
            }
        }
    }
    
    func updateFullWalletInfoInAutoMode(_ walletInfo: WalletInfoDTO, wallets: [WalletModel]) {
        _ = self.apiManager.updateWallets(walletInfo: walletInfo)
            .done { uProfile -> Void in
                let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                SessionStoreManager.saveCurrentUser(user: userDto)
                self.updateWalletsForCurrentUser(wallets)
                self.autoOutput?.manageWalletAutoSuccessfully()
            }.catch({ (error) in
                self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: error as? ConnectionError ?? .systemError, showTryAgain: true)
            })
    }
    
    func manageWalletInAutoMode(isCreateNew: Bool, mnemonics: String, rawPin: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            var wallets = self.walletManager.createNewWallets(mnemonics: mnemonics)
            // Handle wallets empty
            if wallets.count < 2 {
                DispatchQueue.main.async {
                    self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
                }
                return
            }
            for i in 0..<wallets.count {
                wallets[i].privateKey = wallets[i].privateKey.encrypt(key: rawPin)
            }
            let encryptedSeedPhrase = mnemonics.encrypt(key: rawPin)
            _ = self.updateMnemonicAndPinForCurrentUser(mnemonic: encryptedSeedPhrase, pin: rawPin).done(on: .main) { (result) in
                self.updateWalletsToUserProfileInAutoMode(isCreateNew: isCreateNew, mnemonics: mnemonics, rawPin: rawPin, wallets: wallets)
            }.catch(on: .main, { (error) in
                self.autoOutput?.errorWhileManageWalletAutomatically(connectionError: .systemError, showTryAgain: false)
            })
        }
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
