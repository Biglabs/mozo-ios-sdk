//
//  WithdrawModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/20/19.
//

import Foundation
@objc public protocol WithdrawAirdropEventDelegate {
    func withdrawMozoFromAirdropEventSuccess()
    func withdrawMozoFromAirdropEventFailureWithErrorString(error: String?)
    func withdrawMozoFromAirdropEventFailure(error: Error)
}

