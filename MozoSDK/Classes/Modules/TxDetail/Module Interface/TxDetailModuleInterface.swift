//
//  TxDetailModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation

protocol TxDetailModuleInterface {
    func requestAddToAddressBook(_ address: String)
    func requestCloseAllUI()
}
