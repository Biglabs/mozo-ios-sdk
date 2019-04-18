//
//  SafetyDataManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/23/18.
//

import Foundation

class SafetyDataManager {
    static let shared = SafetyDataManager()
    // MARK: Address book - Serial dispatch queue
    private let addressBookLockQueue = DispatchQueue(label: "SafetyDataManager.AddressBook.lockQueue")
    
    private var _addressBookList : [AddressBookDTO]
    
    public var addressBookList : [AddressBookDTO] {
        get {
            print("Get address book list")
            return addressBookLockQueue.sync {
                return self._addressBookList
            }
        }
        set {
            print("Set address book list")
            addressBookLockQueue.sync {
                self._addressBookList = newValue
            }
        }
    }
    // MARK: Store book - Serial dispatch queue
    private let storeBookLockQueue = DispatchQueue(label: "SafetyDataManager.StoreBook.lockQueue")
    
    private var _storeBookList : [StoreBookDTO]
    
    public var storeBookList : [StoreBookDTO] {
        get {
            print("Get store book list")
            return storeBookLockQueue.sync {
                return self._storeBookList
            }
        }
        set {
            print("Set store book list")
            storeBookLockQueue.sync {
                self._storeBookList = newValue
            }
        }
    }
    // MARK: Detail display data (Only for Mozo UI components) - Serial dispatch queue
    // OFFCHAIN
    private let offchainDetailDisplayDataLockQueue = DispatchQueue(label: "SafetyDataManager.DisplayData.Offchain.lockQueue")
    
    private var _offchainDetailDisplayData : DetailInfoDisplayItem?
    
    public var offchainDetailDisplayData : DetailInfoDisplayItem? {
        get {
            print("Get detail display data for MozoX offchain")
            return self._offchainDetailDisplayData
        }
        set {
            print("Set detail display data for MozoX offchain")
            offchainDetailDisplayDataLockQueue.sync {
                self._offchainDetailDisplayData = newValue
            }
        }
    }
    
    private let onchainFromOffchainDetailDisplayDataLockQueue = DispatchQueue(label: "SafetyDataManager.DisplayData.OnchainFromOffchain.lockQueue")
    
    private var _onchainFromOffchainDetailDisplayData : DetailInfoDisplayItem?
    
    public var onchainFromOffchainDetailDisplayData : DetailInfoDisplayItem? {
        get {
            print("Get detail display data of onchain for MozoX offchain")
            return self._onchainFromOffchainDetailDisplayData
        }
        set {
            print("Set detail display data of onchain for MozoX offchain")
            onchainFromOffchainDetailDisplayDataLockQueue.sync {
                self._onchainFromOffchainDetailDisplayData = newValue
            }
        }
    }
    
    // ONCHAIN
    private let onchainDetailDisplayDataLockQueue = DispatchQueue(label: "SafetyDataManager.DisplayData.Onchain.lockQueue")
    
    private var _onchainDetailDisplayData : DetailInfoDisplayItem?
    
    public var onchainDetailDisplayData : DetailInfoDisplayItem? {
        get {
            print("Get detail display data for MozoX onchain")
            return self._onchainDetailDisplayData
        }
        set {
            print("Set detail display data for MozoX onchain")
            onchainDetailDisplayDataLockQueue.sync {
                self._onchainDetailDisplayData = newValue
            }
        }
    }
    
    // ETH
    private let ethDetailDisplayDataLockQueue = DispatchQueue(label: "SafetyDataManager.DisplayData.ETH.lockQueue")
    
    private var _ethDetailDisplayData : DetailInfoDisplayItem?
    
    public var ethDetailDisplayData : DetailInfoDisplayItem? {
        get {
            print("Get detail display data for ETH")
            return self._ethDetailDisplayData
        }
        set {
            print("Set detail display data for ETH")
            ethDetailDisplayDataLockQueue.sync {
                self._ethDetailDisplayData = newValue
            }
        }
    }
    // MARK: Initialization
    private init() {
        _addressBookList = []
        _storeBookList = []
        _checkTokenExpiredStatus = CheckTokenExpiredStatus.IDLE
    }
    
    // MARK: CheckTokenExpiredStatus - Serial dispatch queue
    private let checkTokenExpiredStatusQueue = DispatchQueue(label: "SafetyDataManager.checkTokenExpiredStatus.lockQueue")
    
    private var _checkTokenExpiredStatus : CheckTokenExpiredStatus
    
    public var checkTokenExpiredStatus : CheckTokenExpiredStatus {
        get {
            print("Get check Token Expired Status")
            return checkTokenExpiredStatusQueue.sync {
                return self._checkTokenExpiredStatus
            }
        }
        set {
            print("Set check Token Expired Status")
            checkTokenExpiredStatusQueue.sync {
                self._checkTokenExpiredStatus = newValue
            }
        }
    }
}
