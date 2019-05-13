//
//  ResetPINInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/8/19.
//

import Foundation
class ResetPINInteractor: NSObject {
    var output: ResetPINInteractorOutput?
    
    let walletManager : WalletManager
    let dataManager : WalletDataManager
    let apiManager : ApiManager
    
    init(walletManager: WalletManager, dataManager: WalletDataManager, apiManager: ApiManager) {
        self.walletManager = walletManager
        self.dataManager = dataManager
        self.apiManager = apiManager
    }
    
    func updateMnemonicAndPinForCurrentUser(wallets: [WalletModel], mnemonic: String, pin: String) {
        if let userObj = SessionStoreManager.loadCurrentUser() {
            _ = dataManager.updateMnemonic(mnemonic, id: userObj.id!, pin: pin).done { (result) in
                self.updateWalletsToUserProfile(wallets: wallets)
            }.catch { (error) in
                self.output?.manageResetFailedWithError(.systemError)
            }
        } else {
            self.output?.manageResetFailedWithError(.systemError)
        }
    }
    
    func updateWalletsForCurrentUser(_ wallets: [WalletModel]){
        if let userObj = SessionStoreManager.loadCurrentUser() {
            for wallet in wallets {
                dataManager.updateWallet(wallet, id: userObj.id!)
            }
        }
    }
    
    func updateWalletsToUserProfile(wallets: [WalletModel]) {
        print("ResetPINInteractor - Update wallet to user profile")
        if wallets.count < 2 {
            self.output?.manageResetFailedWithError(.systemError)
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
                    self.output?.manageResetFailedWithError(.systemError)
                    return
                }
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
                if serverWalletInfo.offchainAddress != nil, serverWalletInfo.onchainAddress != nil {
                    if numberOfLocalWallets == 2 {
                        
                    } else if numberOfLocalWallets == 1 {
                        self.updateWalletsForCurrentUser([onchainWallet])
                    } else { // 0
                        self.updateWalletsForCurrentUser(wallets)
                    }
                    self.output?.resetPINSuccess()
                } else if serverWalletInfo.offchainAddress != nil, serverWalletInfo.onchainAddress == nil {
                    if numberOfLocalWallets == 2 {
                        self.updateOnchainAddressToServer(walletsNeedToBeSavedAtLocal: [])
                    } else if numberOfLocalWallets == 1 {
                        _ = self.apiManager.updateOnlyOnchainWallet(onchainAddress: onchainAddress).done({ (uProfile) in
                            let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                            SessionStoreManager.saveCurrentUser(user: userDto)
                            print("ResetPINInteractor - Update Wallet To User Profile result: [\(uProfile)]")
                            self.updateWalletsForCurrentUser([onchainWallet])
                            self.output?.resetPINSuccess()
                        }).catch({ (error) in
                            self.output?.manageResetFailedWithError(error as? ConnectionError ?? .systemError)
                        })
                    } else {
                        _ = self.apiManager.updateOnlyOnchainWallet(onchainAddress: onchainAddress).done({ (uProfile) in
                            let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                            SessionStoreManager.saveCurrentUser(user: userDto)
                            print("ResetPINInteractor - Update Wallet To User Profile result: [\(uProfile)]")
                            self.updateWalletsForCurrentUser(wallets)
                            self.output?.resetPINSuccess()
                        }).catch({ (error) in
                            self.output?.manageResetFailedWithError(error as? ConnectionError ?? .systemError)
                        })
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
                print("ResetPINInteractor - Update Wallet To User Profile result: [\(uProfile)]")
                self.updateWalletsForCurrentUser(wallets)
                self.output?.resetPINSuccess()
            }.catch({ (error) in
                self.output?.manageResetFailedWithError(error as? ConnectionError ?? .systemError)
            })
    }
    
    func updateOnchainAddressToServer(walletsNeedToBeSavedAtLocal: [WalletModel]) {
        print("ResetPINInteractor - Update onchain address to server")
        if let userObj = SessionStoreManager.loadCurrentUser(), let userId = userObj.id, let offchainAddress = userObj.profile?.walletInfo?.offchainAddress {
            _ = dataManager.getOnchainAddressByUserId(userId, offchainAddress: offchainAddress).done { (onchainAddress) in
                self.apiManager.updateOnlyOnchainWallet(onchainAddress: onchainAddress).done({ (uProfile) in
                    let userDto = UserDTO(id: uProfile.userId, profile: uProfile)
                    SessionStoreManager.saveCurrentUser(user: userDto)
                    print("ResetPINInteractor - Update Wallet To User Profile result: [\(uProfile)]")
                    if walletsNeedToBeSavedAtLocal.count > 0 {
                        self.updateWalletsForCurrentUser(walletsNeedToBeSavedAtLocal)
                    }
                    self.output?.resetPINSuccess()
                }).catch({ (error) in
                    self.output?.manageResetFailedWithError(error as? ConnectionError ?? .systemError)
                })
            }.catch { (error) in
                self.output?.manageResetFailedWithError(.systemError)
            }
        } else {
            self.output?.manageResetFailedWithError(.systemError)
        }
    }
}
extension ResetPINInteractor: ResetPINInteractorInput {
    func validateMnemonics(_ mnemonics: String) {
        let result = self.walletManager.validateMnemonicsString(withString: mnemonics)
        if result {
            output?.allowGoNext()
        } else {
            output?.disallowGoNext()
        }
    }
    
    func validateMnemonicsForRestore(_ mnemonics: String) {
        let result = self.walletManager.validateMnemonicsString(withString: mnemonics)
        if result {
            let wallets = walletManager.createNewWallets(mnemonics: mnemonics)
            if wallets.count > 0 {
                let justCreatedOffchainAddress = wallets[0].address
                if let walletInfo = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
                    let offchainAddress = walletInfo.offchainAddress,
                    justCreatedOffchainAddress.lowercased() == offchainAddress.lowercased() {
                    output?.requestEnterNewPIN(mnemonics: mnemonics)
                    return
                }
            }
            output?.mnemonicsNotBelongToUserWallet()
        } else {
            output?.validateFailedForRestore()
        }
    }
    
    func manageResetPINForWallet(_ mnemonics: String, pin: String) {
        var wallets = walletManager.createNewWallets(mnemonics: mnemonics)
        if wallets.count == 2 {
            let encryptedMnemonics = mnemonics.encrypt(key: pin)
            
            for i in 0..<wallets.count {
                wallets[i].privateKey = wallets[i].privateKey.encrypt(key: pin)
            }
            
            let offchainWallet = wallets[0]
            let offchainAddress = offchainWallet.address
            let onchainWallet = wallets[1]
            let onchainAddress = onchainWallet.address
            
            let updatingWalletInfo = WalletInfoDTO(encryptSeedPhrase: encryptedMnemonics, offchainAddress: offchainAddress, onchainAddress: onchainAddress)
            _ = apiManager.resetPINOfUserWallet(walletInfo: updatingWalletInfo).done { (userProfile) in
                self.updateMnemonicAndPinForCurrentUser(wallets: wallets, mnemonic: encryptedMnemonics, pin: pin)
            }.catch { (error) in
                self.output?.manageResetFailedWithError(error as? ConnectionError ?? .systemError)
            }
        } else {
            self.output?.manageResetFailedWithError(.systemError)
        }
    }
}
