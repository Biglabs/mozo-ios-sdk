//
//  TopUpModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
protocol TopUpModuleDelegate {
    func didConfirmTopUpTransaction(_ tx: TransactionDTO)
}
@objc public protocol TopUpDelegate {
    func topUpSuccess()
    func topUpFailureWithErrorString(error: String?, isDisplayingTryAgain: Bool)
    func topUpFailure(error: Error, isDisplayingTryAgain: Bool)
    func didCancelTryAgain()
}
