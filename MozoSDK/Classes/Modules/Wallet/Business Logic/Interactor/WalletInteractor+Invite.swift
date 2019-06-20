//
//  WalletInteractor+Invite.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/2/19.
//

import Foundation
let WAITING_CHECKING_PROCESSING_INVITATION_TIME_OUT_AFTER_SECONDS = 90 * 3
extension WalletInteractor {
    func setupTimerWaitingInvitation(updatingWalletInfo: WalletInfoDTO, wallets: [WalletModel], inAutoMode: Bool = false) {
        self.startDateWaitingForCheckingProcessingInvitation = Date().addingTimeInterval(TimeInterval(WAITING_CHECKING_PROCESSING_INVITATION_TIME_OUT_AFTER_SECONDS))
        print("Set up timer - waiting for processing invitation")
        self.tempWalletInfo = updatingWalletInfo
        self.tempWallets = wallets
        let selector = inAutoMode ? #selector(self.repeatCheckForProcessingInvitationInAutoMode) : #selector(self.repeatCheckForProcessingInvitation)
        self.checkProcessingInvitationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: selector, userInfo: nil, repeats: true)
    }
    
    @objc func repeatCheckForProcessingInvitation() {
        if SafetyDataManager.shared.checkProcessingInvitation == false {
            continueWithUpdatingFullyWallet()
            return
        }
        if Date() > self.startDateWaitingForCheckingProcessingInvitation {
            SafetyDataManager.shared.checkProcessingInvitation = true
        }
    }
    
    func continueWithUpdatingFullyWallet() {
        checkProcessingInvitationTimer?.invalidate()
        print("Continue with updating full wallets.")
        if let tempWalletInfo = self.tempWalletInfo, self.tempWallets.count > 0 {
            self.updateFullWalletInfo(tempWalletInfo, wallets: tempWallets)
        }
    }
    
    //MARK: Auto Mode
    @objc func repeatCheckForProcessingInvitationInAutoMode() {
        if SafetyDataManager.shared.checkProcessingInvitation == false {
            continueWithUpdatingFullyWalletInAutoMode()
            return
        }
        if Date() > self.startDateWaitingForCheckingProcessingInvitation {
            SafetyDataManager.shared.checkProcessingInvitation = true
        }
    }
    
    func continueWithUpdatingFullyWalletInAutoMode() {
        checkProcessingInvitationTimer?.invalidate()
        print("Continue with updating full wallets in auto mode.")
        if let tempWalletInfo = self.tempWalletInfo, self.tempWallets.count > 0 {
            self.updateFullWalletInfoInAutoMode(tempWalletInfo, wallets: tempWallets)
        }
    }
}
