//
//  AirdropModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation

@objc public protocol MultiSignDelegate {
    func mozoMultiSignSuccess(signature: Signature)
}

@objc public protocol AirdropEventDelegate {
    func createAirdropEventSuccess()
    func createAirdropEventFailureWithErrorString(error: String?, isDisplayingTryAgain: Bool)
    func createAirdropEventFailure(error: Error, isDisplayingTryAgain: Bool)
    func didCancelTryAgain()
}
