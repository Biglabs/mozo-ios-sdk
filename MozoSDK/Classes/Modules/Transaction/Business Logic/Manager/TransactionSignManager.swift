//
//  TransactionSignManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/21/18.
//

import Foundation
import PromiseKit
import web3swift

public class TransactionSignManager {
    let dataManager : TransactionDataManager
    
    init(dataManager: TransactionDataManager) {
        self.dataManager = dataManager
    }
    
    public func signTransaction(_ interTx: IntermediaryTransactionDTO, pin: String) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, let userId = profile.userId {
                _ = dataManager.getWalletByUserId(userId).done({ (wallet) in
                    if !wallet.privateKey.isEmpty {
                        let signature = Signature(tosigns: interTx.tosign ?? [])
                        let signedResult = self.sign(wallet.privateKey, pin: pin, signature: signature)
                        
                        interTx.signatures = signedResult.signatures
                        interTx.pubkeys = signedResult.publicKeys
                        
                        seal.fulfill(interTx)
                    }
                })
            }
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
