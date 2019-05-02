//
//  WalletInteractor+Invite.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/2/19.
//

import Foundation
let WAITING_CHECKING_PROCESSING_INVITATION_TIME_OUT_AFTER_SECONDS = 90 * 3
extension WalletInteractor {
    func setupTimerWaitingInvitation(updatingWalletInfo: WalletInfoDTO, wallets: [WalletModel]) {
        self.startDateWaitingForCheckingProcessingInvitation = Date().addingTimeInterval(TimeInterval(WAITING_CHECKING_PROCESSING_INVITATION_TIME_OUT_AFTER_SECONDS))
        print("Set up timer - waiting for processing invitation")
        self.tempWalletInfo = updatingWalletInfo
        self.tempWallets = wallets
        self.checkProcessingInvitationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.repeatCheckForProcessingInvitation), userInfo: nil, repeats: true)
    }
    
    @objc func repeatCheckForProcessingInvitation() {
        if SafetyDataManager.shared.checkProcessingInvitation == false {
            continueWithUpdatingFulllyWallet()
            return
        }
        if Date() > self.startDateWaitingForCheckingProcessingInvitation {
            SafetyDataManager.shared.checkProcessingInvitation = true
        }
    }
    
    func continueWithUpdatingFulllyWallet() {
        checkProcessingInvitationTimer?.invalidate()
        print("Continue with updating full wallets.")
        if let tempWalletInfo = self.tempWalletInfo, self.tempWallets.count > 0 {
            self.updateFullWalletInfo(tempWalletInfo, wallets: tempWallets)
        }
    }
}
