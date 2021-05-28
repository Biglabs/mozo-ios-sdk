//
//  TopUpWithdrawModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/19.
//

import Foundation
@objc public protocol TopUpWithdrawDelegate {
    func topUpWithdrawSuccess()
    func topUpWithdrawFailed()
    func topUpWithdrawFailureWithErrorString(error: String?)
    func topUpWithdrawFailure(error: Error)
    func topUpCancel()
}
