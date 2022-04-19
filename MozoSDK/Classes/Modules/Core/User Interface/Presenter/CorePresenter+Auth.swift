//
//  CorePresenter+Auth.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/24/19.
//

import Foundation

extension CorePresenter : AuthModuleDelegate {
    func didReceiveErrorWhileExchangingCode() {
        "didReceiveErrorWhileExchangingCode".log()
        waitingViewInterface?.displayAlertIncorrectSystemDateTime()
    }
    
    func didCheckAuthorizationSuccess() {
        "On Check Authorization Did Success: Download convenience data".log()
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        readyForGoingLive()
    }
    
    func didCheckAuthorizationFailed() {
        "On Check Authorization Did Failed - No connection".log()
    }
    
    func didRemoveTokenAndLogout() {
        "On Check Authorization Did remove token and logout".log()
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        stopSilentServices(shouldReconnect: false)
        MozoSDK.logout()
    }
    
    func authModuleDidFinishAuthentication(accessToken: String?) {
        "End process authModuleDidFinishAuthentication".log()
        coreInteractor?.handleAferAuth(accessToken: accessToken)
        // Notify for all observing objects
        self.coreInteractor?.notifyAuthSuccessForAllObservers()
    }
    
    func authModuleDidFailedToMakeAuthentication(error: ConnectionError) {
        "End process authModuleDidFailedToMakeAuthentication".log()
        waitingViewInterface?.displayTryAgain(error, forAction: .BuildAuth)
    }
    
    func authModuleDidCancelAuthentication() {
        "End process authModuleDidCancelAuthentication".log()
        requestForCloseAllMozoUIs(nil)
        stopSilentServices(shouldReconnect: false)
    }
    
    private func checkToDismissAccessDeniedIfNeed(callback: (() -> Void)? = nil) {
        let topViewController = DisplayUtils.getTopViewController()
        if let klass = DisplayUtils.getAuthenticationClass(), topViewController?.isKind(of: klass) == true {
            "CorePresenter - \(klass) on top, try to dismiss AccessDeniedViewController after 2s".log()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                if let top = DisplayUtils.getTopViewController(), top is AccessDeniedViewController {
                    top.dismiss(animated: false, completion: callback)
                } else {
                    callback?()
                }
            }
        } else if topViewController is AccessDeniedViewController {
            topViewController?.dismiss(animated: false, completion: callback)
        } else {
            callback?()
        }
    }
    
    func authModuleDidFinishLogout(callback: (() -> Void)?) {
        self.checkToDismissAccessDeniedIfNeed {
            
            // Send delegate back to the app
            self.authDelegate?.mozoLogoutDidFinish()
            // Notify for all observing objects
            self.coreInteractor?.notifyLogoutForAllObservers()
            self.coreInteractor?.stopCheckTokenTimer()
            self.requestForCloseAllMozoUIs {
                self.stopSilentServices(shouldReconnect: false)
                callback?()
            }
        }
    }
    
    func authModuleDidCancelLogout() {
        coreInteractor?.stopCheckTokenTimer()
        "End process authModuleDidCancelLogout".log()
        stopSilentServices(shouldReconnect: false)
    }
    
    func willExecuteNextStep() {
        self.authDelegate?.willExecuteNextStep()
    }
    
    func willRelaunchAuthentication() {
        // MARK: Force start Authentication flow after logout
        coreInteractor?.checkForAuthentication(module: .Wallet)
    }
}
