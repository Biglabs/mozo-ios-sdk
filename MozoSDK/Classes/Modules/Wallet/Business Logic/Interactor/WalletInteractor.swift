//
//  WalletInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import web3swift

class WalletInteractor : NSObject {
    var output : WalletInteractorOutput?
    
    let walletManager : WalletManager
    let dataManager : WalletDataManager
    let apiManager : ApiManager
        
    init(walletManager: WalletManager, dataManager: WalletDataManager, apiManager: ApiManager) {
        self.walletManager = walletManager
        self.dataManager = dataManager
        self.apiManager = apiManager
    }
    
    func updateWalletsForCurrentUser(_ wallets: [WalletModel]){
        if let userObj = SessionStoreManager.loadCurrentUser() {
            for wallet in wallets {
                dataManager.updateWallet(wallet, id: userObj.id!)
            }
        }
    }
    
    func updateMnemonicAndPinForCurrentUser(mnemonic: String, pin: String) {
        if let userObj = SessionStoreManager.loadCurrentUser() {
            dataManager.updateMnemonic(mnemonic, id: userObj.id!, pin: pin)
        }
    }
    
    func updateWalletsToUserProfile(wallets: [WalletModel]) {
        print("WalletInteractor - Update wallet to user profile")
        if wallets.count < 2 {
            self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
            return
        }
        let offchainAddress = wallets[0].address
        let onchainWallet = wallets[1]
        let onchainAddress = onchainWallet.address
        if let userObj = SessionStoreManager.loadCurrentUser(), let serverWalletInfo = userObj.profile?.walletInfo {
            _ = dataManager.getUserById(userObj.id!).done { (user) in
                let numberOfLocalWallets = user.wallets?.count ?? 0
                if numberOfLocalWallets > 2 {
                    self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: true)
                    return
                }
                if serverWalletInfo.offchainAddress != nil, serverWalletInfo.onchainAddress != nil {
                    if numberOfLocalWallets == 2 {
                        self.output?.updatedWallet()
                    } else if numberOfLocalWallets == 1 {
                        self.updateWalletsForCurrentUser([onchainWallet])
                    } else { // 0
                        self.updateWalletsForCurrentUser(wallets)
                    }
                    self.output?.updatedWallet()
                } else if serverWalletInfo.offchainAddress != nil, serverWalletInfo.onchainAddress == nil {
                    if numberOfLocalWallets == 2 {
                        self.updateOnchainAddressToServer(walletsNeedToBeSavedAtLocal: [])
                    } else if numberOfLocalWallets == 1 {
                        _ = self.apiManager.updateOnlyOnchainWallet(onchainAddress: onchainAddress).done({ (uProfile) in
                            let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                            SessionStoreManager.saveCurrentUser(user: userDto)
                            print("Update Wallet To User Profile result: [\(uProfile)]")
                            self.updateWalletsForCurrentUser([onchainWallet])
                            self.output?.updatedWallet()
                        }).catch({ (error) in
                            self.output?.errorWhileManageWallet(connectionError: error as? ConnectionError ?? .systemError, showTryAgain: true)
                        })
                    } else {
                        self.updateWalletsForCurrentUser(wallets)
                        self.output?.updatedWallet()
                    }
                } else {
                    let updatingWalletInfo = WalletInfoDTO(encryptSeedPhrase: user.mnemonic, offchainAddress: offchainAddress, onchainAddress: onchainAddress)
                    self.updateFullWalletInfo(updatingWalletInfo, wallets: wallets)
                }
            }
        }
    }
    
    func updateFullWalletInfo(_ walletInfo: WalletInfoDTO, wallets: [WalletModel]) {
        _ = self.apiManager.updateWallets(walletInfo: walletInfo)
            .done { uProfile -> Void in
                let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                SessionStoreManager.saveCurrentUser(user: userDto)
                print("Update Wallet To User Profile result: [\(uProfile)]")
                self.updateWalletsForCurrentUser(wallets)
                self.output?.updatedWallet()
            }.catch({ (error) in
                if let connError = error as? ConnectionError {
                    self.output?.errorWhileManageWallet(connectionError: connError, showTryAgain: true)
                }
            })
    }
}

extension WalletInteractor : WalletInteractorInput {
    func updateOnchainAddressToServer(walletsNeedToBeSavedAtLocal: [WalletModel]) {
        print("WalletInteractor - Update onchain address to server")
        if let userObj = SessionStoreManager.loadCurrentUser(), let userId = userObj.id {
            _ = dataManager.getOnchainAddressByUserId(userId).done { (onchainAddress) in
                self.apiManager.updateOnlyOnchainWallet(onchainAddress: onchainAddress).done({ (uProfile) in
                    let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                    SessionStoreManager.saveCurrentUser(user: userDto)
                    print("Update Wallet To User Profile result: [\(uProfile)]")
                    if walletsNeedToBeSavedAtLocal.count > 0 {
                        self.updateWalletsForCurrentUser(walletsNeedToBeSavedAtLocal)
                    }
                    self.output?.updatedWallet()
                }).catch({ (error) in
                    
                })
            }.catch { (error) in
                self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
            }
        }
    }
    
    func checkLocalWalletExisting() {
        print("WalletInteractor - Check Local Wallet Existing")
        if let userObj = SessionStoreManager.loadCurrentUser() {
            _ = dataManager.getUserById(userObj.id!).done { (user) in
                self.output?.finishedCheckLocal(result: user.wallets?.count ?? 0)
            }
        }
    }
    
    func checkServerWalletExisting() {
        print("WalletInteractor - Check Server Wallet Existing")
        if let userObj = SessionStoreManager.loadCurrentUser() {
            // Get UserProfile
            let profile = userObj.profile
            self.output?.finishedCheckServer(result: profile?.walletInfo?.encryptSeedPhrase != nil && profile?.walletInfo?.offchainAddress != nil)
        }
    }
    
    func verifyPIN(pin: String) {
        // Get User from UserDefaults
        if let userObj = SessionStoreManager.loadCurrentUser() {
            // Get ManagedUser from User.id
            _ = dataManager.getUserById(userObj.id!).done { (user) in
                var compareResult = false
                var needManageWallet = false
                if user.pin?.isEmpty == false {
                    // Compare PIN
                    compareResult = pin.toSHA512() == user.pin
                    let numberOfLocalWallets = user.wallets?.count ?? 0
                    if let walletInfo = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo {
                        if walletInfo.offchainAddress != nil, walletInfo.onchainAddress != nil {
                            if numberOfLocalWallets < 2 {
                                needManageWallet = true
                            }
                        } else if walletInfo.offchainAddress != nil, walletInfo.onchainAddress == nil {
                            needManageWallet = true
                        } else {
                            needManageWallet = true
                        }
                    }
                } else {
                    needManageWallet = true
                    // Incase: restore wallet from server mnemonics
                    let mnemonic = userObj.profile?.walletInfo?.encryptSeedPhrase?.decrypt(key: pin)
                    // TODO: Handle mnemonic nil here
                    if BIP39.mnemonicsToEntropy(mnemonic!) == nil {
                        print("😞 Invalid mnemonics")
                        compareResult = false
                    } else {
                        self.updateMnemonicAndPinForCurrentUser(mnemonic: (userObj.profile?.walletInfo?.encryptSeedPhrase)!, pin: pin)
                        compareResult = true
                    }
                }
                self.output?.verifiedPIN(pin, result: compareResult, needManagedWallet: needManageWallet)
            }
        }
    }
    
    func manageWallet(_ mnemonics: String?, pin: String) {
        var mne = mnemonics
        if mnemonics == nil {
            // Get user to get mnemonics
            if let userObj = SessionStoreManager.loadCurrentUser() {
                // Get UserProfile
                let profile = userObj.profile
                // Get wallet - mnemonics
                mne = profile?.walletInfo?.encryptSeedPhrase?.decrypt(key: pin)
            }
        } else {
            // A new wallet has just been created.
            updateMnemonicAndPinForCurrentUser(mnemonic: (mne?.encrypt(key: pin))!, pin: pin)
        }
<<<<<<< HEAD
        var wallets = walletManager.createNewWallets(mnemonics: mne!)
        for i in 0..<wallets.count {
            wallets[i].privateKey = wallets[i].privateKey.encrypt(key: pin)
=======
        let wallets = walletManager.createNewWallets(mnemonics: mne!)
        for var wallet in wallets {
            wallet.privateKey = wallet.privateKey.encrypt(key: pin)
>>>>>>> SDK_Version_1.3
        }
        updateWalletsToUserProfile(wallets: wallets)
    }
    
    func verifyConfirmPIN(pin: String, confirmPin: String) {
        let compareResult = (pin == confirmPin)
        self.output?.verifiedPIN(pin, result: compareResult, needManagedWallet: true)
    }
    
    func generateMnemonics(){
        let mnemonics = walletManager.generateMnemonics()
        output?.generatedMnemonics(mnemonic: mnemonics!)
    }
}
