//
//  WalletInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import web3swift
import PromiseKit

class WalletInteractor : NSObject {
    var output : WalletInteractorOutput?
    var autoOutput: WalletInteractorAutoOutput?
    
    let walletManager : WalletManager
    let dataManager : WalletDataManager
    let apiManager : ApiManager
    
    // Update fully wallet
    var checkProcessingInvitationTimer: Timer?
    var tempWalletInfo: WalletInfoDTO?
    var tempWallets: [WalletModel] = []
    var startDateWaitingForCheckingProcessingInvitation = Date()
        
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
    
    func updateMnemonicAndPinForCurrentUser(mnemonic: String, pin: String) -> Promise<Bool> {
        if let userObj = SessionStoreManager.loadCurrentUser() {
            return dataManager.updateMnemonic(mnemonic, id: userObj.id!, pin: pin)
        }
        return Promise { seal in seal.reject(ConnectionError.systemError) }
    }
    
    func updateWalletsToUserProfile(wallets: [WalletModel], mustUpdateLocalPrivateKeys: Bool = false) {
        print("WalletInteractor - Update wallet to user profile")
        if wallets.count < 2 {
            self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
            return
        }
        let offchainWallet = wallets[0]
        let offchainAddress = offchainWallet.address
        let onchainWallet = wallets[1]
        let onchainAddress = onchainWallet.address
        if let userObj = SessionStoreManager.loadCurrentUser(), let serverWalletInfo = userObj.profile?.walletInfo {
            _ = dataManager.getUserById(userObj.id!).done { (user) in
                let numberOfLocalWallets = user.wallets?.count ?? 0
                if numberOfLocalWallets > 2 {
                    self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: true)
                    return
                }
                if mustUpdateLocalPrivateKeys {
                    switch numberOfLocalWallets {
                    case 2:
                        print("WalletInteractor - Update wallet to user profile, update local private keys for offchain and onchain")
                        _ = self.dataManager.updatePrivateKeys(offchainWallet)
                        _ = self.dataManager.updatePrivateKeys(onchainWallet)
                        break
                    case 1:
                        print("WalletInteractor - Update wallet to user profile, update local private keys for offchain only")
                        _ = self.dataManager.updatePrivateKeys(offchainWallet)
                        break
                    default:
                        print("WalletInteractor - Update wallet to user profile, update local private keys for no wallet")
                        break
                    }
                }
                if serverWalletInfo.offchainAddress != nil, serverWalletInfo.onchainAddress != nil {
                    if numberOfLocalWallets == 2 {
                        
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
                        _ = self.apiManager.updateOnlyOnchainWallet(onchainAddress: onchainAddress).done({ (uProfile) in
                            let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                            SessionStoreManager.saveCurrentUser(user: userDto)
                            print("Update Wallet To User Profile result: [\(uProfile)]")
                            self.updateWalletsForCurrentUser(wallets)
                            self.output?.updatedWallet()
                        }).catch({ (error) in
                            self.output?.errorWhileManageWallet(connectionError: error as? ConnectionError ?? .systemError, showTryAgain: true)
                        })
                    }
                } else {
                    let updatingWalletInfo = WalletInfoDTO(encryptSeedPhrase: user.mnemonic, offchainAddress: offchainAddress, onchainAddress: onchainAddress)
                    // Must waiting for processing invitation
                    if SafetyDataManager.shared.checkProcessingInvitation == false {
                        self.updateFullWalletInfo(updatingWalletInfo, wallets: wallets)
                    } else {
                        self.setupTimerWaitingInvitation(updatingWalletInfo: updatingWalletInfo, wallets: wallets)
                    }
                }
            }
        }
    }
    
    func updateFullWalletInfo(_ walletInfo: WalletInfoDTO, wallets: [WalletModel]) {
        _ = self.apiManager.updateWallets(walletInfo: walletInfo)
            .done { uProfile -> Void in
                let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                SessionStoreManager.saveCurrentUser(user: userDto)
                print("WalletInteractor - Update Wallet To User Profile result: [\(uProfile)]")
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
        if let userObj = SessionStoreManager.loadCurrentUser(), let userId = userObj.id, let offchainAddress = userObj.profile?.walletInfo?.offchainAddress {
            _ = dataManager.getOnchainAddressByUserId(userId, offchainAddress: offchainAddress).done { (onchainAddress) in
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
        } else {
            self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
        }
    }
    
    func checkLocalWalletExisting() {
        print("WalletInteractor - Check Local Wallet Existing")
        if let userObj = SessionStoreManager.loadCurrentUser() {
            _ = dataManager.getUserById(userObj.id!).done { (user) in
                let localWalletCounts = user.wallets?.count ?? 0
                if let encryptSeedPhrase = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.encryptSeedPhrase,
                    !encryptSeedPhrase.isEmpty,
                    !(user.mnemonic ?? "").isEmpty,
                    encryptSeedPhrase != user.mnemonic {
                    print("WalletInteractor - New encrypted seed phrase is detected.")
                    self.output?.didDetectDifferentEncryptedSeedPharse()
                    return
                }
                self.output?.finishedCheckLocal(result: localWalletCounts)
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
                        _ = self.updateMnemonicAndPinForCurrentUser(mnemonic: (userObj.profile?.walletInfo?.encryptSeedPhrase)!, pin: pin)
                        compareResult = true
                    }
                }
                self.output?.verifiedPIN(pin, result: compareResult, needManagedWallet: needManageWallet)
            }
        } else {
            // TODO: Handle case no user data
        }
    }
    
    func verifyPINToRecoverFromServerEncryptedPhrase(pin: String) {
        // Get User from UserDefaults
        if let userObj = SessionStoreManager.loadCurrentUser() {
            let mnemonic = userObj.profile?.walletInfo?.encryptSeedPhrase?.decrypt(key: pin)
            if BIP39.mnemonicsToEntropy(mnemonic!) == nil {
                print("😞 Invalid mnemonics")
                self.output?.verifiedPIN(pin, result: false, needManagedWallet: false)
            } else {
                self.output?.verifiedPIN(pin, result: true, needManagedWallet: true)
            }
        } else {
            // TODO: Handle case no user data
            self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
        }
    }
    
    func manageWalletToRecoverFromServerEncryptedPhrase(pin: String) {
        // Get User from UserDefaults
        if let userObj = SessionStoreManager.loadCurrentUser(), let serverEncryptedSeedPhrase = userObj.profile?.walletInfo?.encryptSeedPhrase {
            let mnemonic = serverEncryptedSeedPhrase.decrypt(key: pin)
            _ = updateMnemonicAndPinForCurrentUser(mnemonic: serverEncryptedSeedPhrase, pin: pin).done { (result) in
                if result {
                    var wallets = self.walletManager.createNewWallets(mnemonics: mnemonic)
                    for i in 0..<wallets.count {
                        wallets[i].privateKey = wallets[i].privateKey.encrypt(key: pin)
                    }
                    self.updateWalletsToUserProfile(wallets: wallets, mustUpdateLocalPrivateKeys: true)
                } else {
                    self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
                }
            }.catch({ (error) in
                self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
            })
        } else {
            self.output?.errorWhileManageWallet(connectionError: .systemError, showTryAgain: false)
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
            _ = updateMnemonicAndPinForCurrentUser(mnemonic: (mne?.encrypt(key: pin))!, pin: pin)
        }
        var wallets = walletManager.createNewWallets(mnemonics: mne!)
        for i in 0..<wallets.count {
            wallets[i].privateKey = wallets[i].privateKey.encrypt(key: pin)
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
