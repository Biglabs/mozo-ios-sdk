//
//  AirdropAddModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
@objc public protocol AirdropAddEventDelegate {
    func addMozoToAirdropEventSuccess()
    func addMozoToAirdropEventFailure(error: String?)
}
