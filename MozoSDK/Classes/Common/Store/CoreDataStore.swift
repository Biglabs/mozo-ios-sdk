//
//  CoreDataStore.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/29/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import PromiseKit
import CoreData

internal class CoreDataStore : NSObject {
    internal static let shared = CoreDataStore()
    private let ENTITY_USER = "User"
    private let ENTITY_WALLET = "Wallet"
    
    private lazy var managedContext: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? BaseApplication else { return nil }
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: User
    
    func countById(_ id: String) -> Int {
        let userFetch = NSFetchRequest<NSNumber>(entityName: ENTITY_USER)
        userFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedUser.id), id)
        userFetch.resultType = .countResultType
        let count = try? managedContext?.fetch(userFetch).first?.intValue
        return count ?? 0
    }
    
    func countWalletByUserId(_ id: String) -> Promise<Int> {
        return Promise { seal in
            let fetchRequest = NSFetchRequest<ManagedUser>(entityName: ENTITY_USER)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedUser.id), id)
            let user = try? managedContext?.fetch(fetchRequest).first
            let walletCount = user?.wallets?.count ?? -1
            seal.fulfill(walletCount)
        }
    }
    
    func getUserById(_ id: String) -> Promise<UserModel> {
        return Promise { seal in
            let fetchRequest = NSFetchRequest<ManagedUser>(entityName: ENTITY_USER)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedUser.id), id)
            if let user = try? managedContext?.fetch(fetchRequest).first {
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
            guard let context = managedContext else { return false }
            guard let userEntity = NSEntityDescription.entity(forEntityName: ENTITY_USER, in: context) else { return false }

            let user = NSManagedObject(entity: userEntity, insertInto: context)
            user.setValue(userModel.id, forKeyPath: #keyPath(ManagedUser.id))
            user.setValue(userModel.mnemonic, forKey: #keyPath(ManagedUser.mnemonic))
            user.setValue(userModel.pin, forKey: #keyPath(ManagedUser.pin))
            user.setValue(userModel.wallets, forKey: #keyPath(ManagedUser.wallets))
            
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func updateUser(_ userModel: UserModel) -> Promise<Any?>{
        return Promise { seal in
            guard let context = managedContext, let id = userModel.id else {
                seal.reject(ConnectionError.unknowError)
                return
            }
            
            let fetchRequest = NSFetchRequest<ManagedUser>(entityName: ENTITY_USER)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedUser.id), id)
            if let user = try? context.fetch(fetchRequest).first {
                user.mnemonic = userModel.mnemonic
                user.pin = userModel.pin
                user.wallets = userModel.wallets
                do {
                    try context.save()
                    seal.fulfill(true)
                } catch {
                    seal.reject(ConnectionError.unknowError)
                }
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
    
    // MARK: Wallet
    
    func updateWallet(_ walletModel: WalletModel, toUser id: String) -> Promise<Any?>{
        return Promise { seal in
            guard let context = managedContext,
                  let walletEntity = NSEntityDescription.entity(forEntityName: ENTITY_WALLET, in: context) else {
                seal.reject(ConnectionError.unknowError)
                return
            }
            
            let fetchRequest = NSFetchRequest<ManagedUser>(entityName: ENTITY_USER)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedUser.id), id)
            if let user = try? context.fetch(fetchRequest).first {
                let wallet = NSManagedObject(entity: walletEntity, insertInto: context)
                wallet.setValue(walletModel.address, forKeyPath: #keyPath(ManagedWallet.address))
                wallet.setValue(walletModel.privateKey, forKeyPath: #keyPath(ManagedWallet.privateKey))
                wallet.setValue(user, forKeyPath: #keyPath(ManagedWallet.user))
                user.wallets?.adding(wallet)
                do {
                    try context.save()
                    seal.fulfill(true)
                } catch {
                    seal.reject(ConnectionError.unknowError)
                }
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
    
    func updatePrivateKeysOfWallet(_ walletModel: WalletModel) -> Promise<Bool>{
        return Promise { seal in
            guard let context = managedContext else {
                seal.reject(ConnectionError.unknowError)
                return
            }
            let fetchRequest = NSFetchRequest<ManagedWallet>(entityName: ENTITY_WALLET)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedWallet.address), walletModel.address)
            if let wallet = try? context.fetch(fetchRequest).first {
                wallet.privateKey = walletModel.privateKey
                do {
                    try context.save()
                    seal.fulfill(true)
                } catch {
                    seal.reject(ConnectionError.unknowError)
                }
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
    
    func getWalletByUserId(_ id: String) -> Promise<WalletModel> {
        return Promise { seal in
            let fetchRequest = NSFetchRequest<ManagedUser>(entityName: ENTITY_USER)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedUser.id), id)
            if let user = try? managedContext?.fetch(fetchRequest).first {
                let wallets : [WalletModel]? = user.wallets?.map {
                    let wallet = $0 as! ManagedWallet
                    return WalletModel(address: wallet.address, privateKey: wallet.privateKey)
                }
                if let w = wallets?.first {
                    seal.fulfill(w)
                } else {
                    seal.reject(ConnectionError.unknowError)
                }
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
    
    func getWalletsByUserId(_ id: String) -> Promise<[WalletModel]> {
        return Promise { seal in
            let fetchRequest = NSFetchRequest<ManagedUser>(entityName: ENTITY_USER)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(ManagedUser.id), id)
            if let user = try? managedContext?.fetch(fetchRequest).first {
                let wallets : [WalletModel]? = user.wallets?.map {
                    let wallet = $0 as! ManagedWallet
                    return WalletModel(address: wallet.address, privateKey: wallet.privateKey)
                }
                seal.fulfill(wallets ?? [])
            } else {
                seal.reject(ConnectionError.unknowError)
            }
        }
    }
}

