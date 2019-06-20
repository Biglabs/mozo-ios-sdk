//
//  WalletInteractorIO+Auto.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
protocol WalletInteractorAutoInput {
    func createMnemonicAndPinAutomatically()
    func recoverWalletsAutomatically()
}
protocol WalletInteractorAutoOutput {
    func manageWalletAutoSuccessfully()
    func errorWhileManageWalletAutomatically(connectionError: ConnectionError, showTryAgain: Bool)
}
