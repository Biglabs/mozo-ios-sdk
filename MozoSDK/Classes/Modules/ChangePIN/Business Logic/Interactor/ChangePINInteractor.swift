//
//  ChangePINInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINInteractor: NSObject {
    var output: ChangePINInteractorOutput?
    
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
                self.updatePrivateKeys(wallets)
                self.output?.changePINSuccess()
            }.catch { (error) in
                self.output?.changePINFailedWithError(.systemError)
            }
        } else {
            self.output?.changePINFailedWithError(.systemError)
        }
    }
    
    func updatePrivateKeys(_ wallets: [WalletModel]){
        let offchainWallet = wallets[0]
        let onchainWallet = wallets[1]
        _ = self.dataManager.updatePrivateKeys(offchainWallet)
        _ = self.dataManager.updatePrivateKeys(onchainWallet)
    }
    
    func manageChangePINForWallet(_ encryptedSeedPhrase: String, currentPIN: String, pin: String) {
        DispatchQueue.global(qos: .background).async { [self] in
            let mnemonics = encryptedSeedPhrase.decrypt(key: currentPIN)
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
                DispatchQueue.main.async {
                    _ = apiManager.updateWalletsForChangingPIN(walletInfo: updatingWalletInfo).done { (userProfile) in
                        let userDto = UserDTO(id: userProfile.userId, profile: userProfile)
                        SessionStoreManager.saveCurrentUser(user: userDto)
                        self.updateMnemonicAndPinForCurrentUser(wallets: wallets, mnemonic: encryptedMnemonics, pin: pin)
                    }.catch { (error) in
                        self.output?.changePINFailedWithError(error as? ConnectionError ?? .systemError)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.output?.changePINFailedWithError(.systemError)
                }
            }
        }
    }
}
extension ChangePINInteractor: ChangePINInteractorInput {
    func changePIN(currentPIN: String, newPIN: String) {
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo,
            let encryptedSeedPhrase = wallet.encryptSeedPhrase {
            self.manageChangePINForWallet(encryptedSeedPhrase, currentPIN: currentPIN, pin: newPIN)
        } else {
            // System error
            self.output?.changePINFailedWithError(.systemError)
        }
    }
}
