//
//  CoreDataStore.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/29/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import PromiseKit
import CoreStore

class CoreDataStore : NSObject {
    public static let shared = CoreDataStore()
    
    var stack : DataStack!
    
    override init() {
        super.init()
        let bundle = BundleManager.podBundle()
        stack = DataStack(
            xcodeModelName: "Mozo",
            bundle: bundle
        )
        let sqliteStore = SQLiteStore(
            fileName: "Mozo.sqlite",
            localStorageOptions: .recreateStoreOnModelMismatch // Provides settings that tells the DataStack how to setup the persistent store
        )
        do {
            try stack.addStorageAndWait(sqliteStore)
        } catch {
            print("Add storage error: [\(error)]")
        }
    }
    
    // MARK: User
    
    func countById(_ id: String) -> Int? {
        let count = try? stack.fetchCount(From<ManagedUser>().where(\.id == id))
        return count
    }
    
    func countWalletByUserId(_ id: String) -> Promise<Int> {
        return Promise { seal in
            if let user = try? stack.fetchOne(From<ManagedUser>().where(\.id == id)) {
                let count = user.wallets?.count ?? -1
                print("Wallets count: [\(count)]")
                seal.fulfill(count)
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
    
    func getUserById(_ id: String) -> Promise<UserModel>{
        return Promise { seal in
            if let user = try? stack.fetchOne(From<ManagedUser>().where(\.id == id)) {
                print("Wallets count: [\(user.wallets?.count ?? -1)]")
                let wallets : [WalletModel]? = user.wallets?.map {
                    let wallet = $0 as! ManagedWallet
                    return WalletModel(address: wallet.address, privateKey: wallet.privateKey)
                }
                let userModel = UserModel(id: user.id, mnemonic: user.mnemonic, pin: user.pin, wallets: NSSet(array: wallets!))
                seal.fulfill(userModel)
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }

    func addNewUser(userModel: UserModel) -> Bool {
        do {
            _ = try stack.perform(synchronous: { (transaction) -> ManagedUser in
                let userEntity = transaction.create(Into<ManagedUser>())
                userEntity.id = userModel.id!
                return userEntity
            })
        } catch {
            print("Failed to add new user, error: [\(error)]")
            return false
        }
        return true
    }
    
    func newUser(userModel: UserModel) -> Promise<Any?>{
        return Promise { seal in
            stack.perform(asynchronous: { (transaction) -> ManagedUser in
                let userEntity = transaction.create(Into<ManagedUser>())
                userEntity.id = userModel.id!
                return userEntity
            }, success: { (userTransaction) in
                let newUser = self.stack.fetchExisting(userTransaction)!
                print("Success to add new user, id: [\(newUser.id)]")
                seal.fulfill(true)
            }, failure: { (csError) in
                print("Failed to add new user, error: [\(csError)]")
                seal.reject(csError)
            })
        }
    }
    
    func updateUser(_ userModel: UserModel) -> Promise<Any?>{
        return Promise { seal in
            stack.perform(asynchronous: { (transaction) -> ManagedUser in
                let userEntity = try transaction.fetchOne(
                    From<ManagedUser>()
                        .where(\.id == userModel.id!)
                )
                userEntity?.mnemonic = userModel.mnemonic
                userEntity?.pin = userModel.pin
                
                return userEntity!
            }, success: { (userTransaction) in
                let newUser = self.stack.fetchExisting(userTransaction)!
                print("😁 Success to update user, mnemonic: [\(newUser.mnemonic ?? "")]")
                seal.fulfill(true)
            }, failure: { (csError) in
                print("😞 Failed to update user, error: [\(csError)]")
                seal.reject(csError)
            })
        }
    }
    
    // MARK: Wallet
    
    func updateWallet(_ walletModel: WalletModel, toUser id: String) -> Promise<Any?>{
        return Promise { seal in
            stack.perform(asynchronous: { (transaction) -> ManagedUser in
                let userEntity = try transaction.fetchOne(
                    From<ManagedUser>()
                        .where(\.id == id)
                )
                let walletEntity = transaction.create(Into<ManagedWallet>())
                walletEntity.address = walletModel.address
                walletEntity.privateKey = walletModel.privateKey
                walletEntity.user = userEntity!
                
                userEntity?.wallets?.adding(walletEntity)
        
                return userEntity!
            }, success: { (userTransaction) in
                let newUser = self.stack.fetchExisting(userTransaction)!
                print("😁 Success to update wallet to user, wallet count: [\(newUser.wallets?.count ?? 0)]")
                seal.fulfill(true)
            }, failure: { (csError) in
                print("😞 Failed to update wallet to user, error: [\(csError)]")
                seal.reject(csError)
            })
        }
    }
    
    func updatePrivateKeysOfWallet(_ walletModel: WalletModel) -> Promise<Bool>{
        return Promise { seal in
            stack.perform(asynchronous: { (transaction) -> ManagedWallet in
                let walletEntity = try transaction.fetchOne(
                    From<ManagedWallet>()
                        .where(\.address == walletModel.address)
                )
                print("Update private key \(walletEntity?.privateKey ?? "") with private key \(walletModel.privateKey)")
                walletEntity?.privateKey = walletModel.privateKey
                
                return walletEntity!
            }, success: { (transaction) in
                let wallet = self.stack.fetchExisting(transaction)!
                print("😁 Success to update private key of wallet, new private key: \(wallet.privateKey)")
                seal.fulfill(true)
            }, failure: { (csError) in
                print("😞 Failed to update private key of wallet, error: [\(csError)]")
                seal.reject(csError)
            })
        }
    }
    
    func getWalletByUserId(_ id: String) -> Promise<WalletModel>{
        return Promise { seal in
            if let userEntity = try stack.fetchOne(From<ManagedUser>().where(\.id == id)) {
                print("Wallets count: [\(userEntity.wallets?.count ?? -1)]")
                let wallets : [WalletModel]? = userEntity.wallets?.map {
                    let wallet = $0 as! ManagedWallet
                    return WalletModel(address: wallet.address, privateKey: wallet.privateKey)
                }
                seal.fulfill((wallets?.first)!)
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
    
    func getWalletsByUserId(_ id: String) -> Promise<[WalletModel]>{
        return Promise { seal in
            if let userEntity = try stack.fetchOne(From<ManagedUser>().where(\.id == id)) {
                let wallets : [WalletModel]? = userEntity.wallets?.map {
                    let wallet = $0 as! ManagedWallet
                    return WalletModel(address: wallet.address, privateKey: wallet.privateKey)
                }
                seal.fulfill(wallets ?? [])
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
    
    func getAllUsers() {
        if let list = try? stack.fetchAll(From<ManagedUser>()) {
            for item in list {
                let wallets : [WalletModel]? = item.wallets?.map {
                    let wallet = $0 as! ManagedWallet
                    return WalletModel(address: wallet.address, privateKey: wallet.privateKey)
                }
                if let wallets = wallets {
                    for wallet in wallets {
                        print("Wallet: \(wallet)")
                    }
                }
            }
        } else {
            
        }
    }
}

