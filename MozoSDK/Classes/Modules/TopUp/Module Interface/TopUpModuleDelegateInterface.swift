//
//  TopUpModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
protocol TopUpConfirmModuleDelegate {
    func didConfirmTopUpTransaction(_ tx: TransactionDTO, tokenInfo: TokenInfoDTO)
}
protocol TopUpCompletionModuleDelegate {
    func didTopUpCompleteFailure()
}
@objc public protocol TopUpDelegate {
    func requestGetToken()
}
