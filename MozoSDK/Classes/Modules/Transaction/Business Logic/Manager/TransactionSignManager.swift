//
//  TransactionSignManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/21/18.
//

import Foundation
import PromiseKit
import web3swift

public typealias Triple = (var1: String, var2: String, var3: String)

public class TransactionSignManager {
    public static let shared = TransactionSignManager()
    let notiReceivePin = "RequestForPin"
    let dataManager : TransactionDataManager
    
    private var signCallback: (([Triple]?) -> ())? = nil
    private var signData: [String]? = nil
    
    init() {
        let txDataManager = TransactionDataManager()
        txDataManager.coreDataStore = CoreDataStore.shared
        self.dataManager = txDataManager
    }
    
    @objc func onResultReceived(_ notification: Notification) {
        guard let pin = notification.userInfo?["pin"] as? String else {
            signCallback?(nil)
            signCallback = nil
            signData = nil
            return
        }
        self.sign(pin)
    }
    
    public func signMessages(toSigns: [String], _ completion: @escaping ([Triple]?) -> ()) {
        signData = toSigns
        signCallback = completion
        
        if let encryptedPin = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.encryptedPin,
            let pinSecret = AccessTokenManager.getPinSecret() {
            let decryptPin = encryptedPin.decrypt(key: pinSecret)
            if SessionStoreManager.getNotShowAutoPINScreen() == true {
                sign(decryptPin)
            } else {
                // MARK: redeemWF?.presentAutoPINInterface(needShowRoot: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Configuration.TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS) + .milliseconds(1)) {
                    self.sign(decryptPin)
                }
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onResultReceived(_:)), name: Notification.Name(notiReceivePin), object: nil)
            // MARK: redeemWF?.presentPinInterface()
        }
    }
    
    public func signTransaction(_ interTx: IntermediaryTransactionDTO, pin: String) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, let userId = profile.userId {
                _ = dataManager.getAllWalletsByUserId(userId).done({ (wallets) in
                    if let privateKey = self.findPrivateKey(interTx, wallets: wallets), !privateKey.isEmpty {
                        let signature = Signature(tosigns: interTx.tosign ?? [])
                        let signedResult = self.sign(privateKey, pin: pin, signature: signature)
                        
                        interTx.signatures = signedResult.signatures
                        interTx.pubkeys = signedResult.publicKeys
                        
                        seal.fulfill(interTx)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                })
            }
        }
    }
    
    func sign(_ pin: String) {
        if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, let userId = profile.userId {
            _ = dataManager.getAllWalletsByUserId(userId).done({ (wallets) in
                if let privateKey = self.findPrivateKey(profile.walletInfo?.offchainAddress, wallets: wallets), !privateKey.isEmpty, self.signData != nil, !self.signData!.isEmpty {
                    
                    let decryptedPrivateKey = privateKey.decrypt(key: pin)
                    guard let publicKey = Web3Utils.privateToPublic(Data(hex: decryptedPrivateKey))?.dropFirst().toHexString().addHexPrefix()
                    else {
                        // MARK: PIN is wrong
                        return
                    }
                    
                    var result: [Triple] = []
                    self.signData!.forEach { d in
                        let tosign = d.replace("0x", withString: "")
                        if let signature = tosign.ethSign(privateKey: decryptedPrivateKey) {
                            result.append(Triple(d, signature, publicKey))
                        }
                    }
                    // MARK: self.redeemWF?.dismissAutoPinIfNeed()
                    self.signCallback?(result)
                    self.signCallback = nil
                    self.signData = nil
                    
                } else {
                    // MARK: self.redeemWF?.dismissAutoPinIfNeed()
                    self.signCallback?(nil)
                    self.signCallback = nil
                    self.signData = nil
                }
            })
        } else {
            // MARK: redeemWF?.dismissAutoPinIfNeed()
            signCallback?(nil)
            signCallback = nil
            self.signData = nil
        }
    }
    
    func sign(_ privateKey: String, pin: String, signature: Signature) -> Signature {
        let decryptedPrivateKey = privateKey.decrypt(key: pin)
        let buffer = Data(hex: decryptedPrivateKey)
        var signatures : [String] = []
        var publicKeys : [String] = []
        let tosigns = signature.tosigns ?? []
        for tosignText in signature.tosigns ?? [] {
            let tosign = tosignText.replace("0x", withString: "")
            
            let publicData = Web3Utils.privateToPublic(buffer)?.dropFirst()
            if let publicStr = publicData?.toHexString().addHexPrefix() {
                publicKeys.append(publicStr)
            }
            
            if let signature = tosign.ethSign(privateKey: decryptedPrivateKey) {
                signatures.append(signature)
            }
        }
        let result = Signature(tosigns: tosigns, signatures: signatures, publicKeys: publicKeys)
        return result
    }
    
    func findPrivateKey(_ address: String?, wallets: [WalletModel]) -> String? {
        if let inputAddress = address {
            for wallet in wallets {
                if wallet.address.lowercased() == inputAddress.lowercased() {
                    return wallet.privateKey
                }
            }
        }
        return nil
    }
    
    func findPrivateKey(_ interTx: IntermediaryTransactionDTO, wallets: [WalletModel]) -> String? {
        if let inputAddress = interTx.tx?.inputs?[0].addresses?[0] {
            for wallet in wallets {
                if wallet.address.lowercased() == inputAddress.lowercased() {
                    return wallet.privateKey
                }
            }
        }
        return nil
    }
    
    public func signMultiTransaction(_ interTxArray: [IntermediaryTransactionDTO], pin: String) -> Promise<[IntermediaryTransactionDTO]> {
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, let userId = profile.userId {
                _ = dataManager.getAllWalletsByUserId(userId).done({ (wallets) in
                        var interTxResult : [IntermediaryTransactionDTO] = []
                        for interTx in interTxArray {
                            if let privateKey = self.findPrivateKey(interTx, wallets: wallets), !privateKey.isEmpty {
                                let signature = Signature(tosigns: interTx.tosign ?? [])
                                let signedResult = self.sign(privateKey, pin: pin, signature: signature)
                                
                                interTx.signatures = signedResult.signatures
                                interTx.pubkeys = signedResult.publicKeys
                                
                                interTxResult.append(interTx)
                            }
                        }
                        seal.fulfill(interTxResult)
                })
            }
        }
    }
    
    public func signMultiSignature(_ signature: Signature, pin: String) -> Promise<Signature> {
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, let userId = profile.userId {
                _ = dataManager.getWalletByUserId(userId).done({ (wallet) in
                    if !wallet.privateKey.isEmpty {
                        let signedResult = self.sign(wallet.privateKey, pin: pin, signature: signature)
                        seal.fulfill(signedResult)
                    }
                })
            }
        }
    }
}
