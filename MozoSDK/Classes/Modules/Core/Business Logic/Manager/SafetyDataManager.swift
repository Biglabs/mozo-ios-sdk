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
    // MARK: Detail display data (Only for Mozo UI components) - Serial dispatch queue
    private let detailDisplayDataLockQueue = DispatchQueue(label: "SafetyDataManager.DisplayData.lockQueue")
    
    private var _detailDisplayData : DetailInfoDisplayItem?
    
    public var detailDisplayData : DetailInfoDisplayItem? {
        get {
            print("Get detail display data")
            return self._detailDisplayData
        }
        set {
            print("Set detail display data")
            detailDisplayDataLockQueue.sync {
                self._detailDisplayData = newValue
            }
        }
    }
    
    // MARK: Initialization
    private init() {
        _addressBookList = []
    }
}
