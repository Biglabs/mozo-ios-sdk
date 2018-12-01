//
//  WaitingViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/29/18.
//

import Foundation
class WaitingViewController: MozoBasicViewController {
    var eventHandler: CoreModuleWaitingInterface?
}
extension WaitingViewController : PopupErrorDelegate {
    func didTouchTryAgainButton() {
        print("User try reload user profile on waiting screen again.")
        removeMozoPopupError()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.eventHandler?.retryGetUserProfile()
        }
    }
}
extension WaitingViewController: WaitingViewInterface {
    func displayTryAgain(_ error: ConnectionError) {
        displayMozoPopupError()
        mozoPopupErrorView?.delegate = self
    }
}
