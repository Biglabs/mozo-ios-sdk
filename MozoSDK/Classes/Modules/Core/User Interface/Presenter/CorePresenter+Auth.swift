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
        isProcessing = false
        "End process authModuleDidFinishAuthentication".log()
        coreInteractor?.handleAferAuth(accessToken: accessToken)
        // Notify for all observing objects
        self.coreInteractor?.notifyAuthSuccessForAllObservers()
    }
    
    func authModuleDidFailedToMakeAuthentication(error: ConnectionError) {
        isProcessing = false
        "End process authModuleDidFailedToMakeAuthentication".log()
        waitingViewInterface?.displayTryAgain(error, forAction: .BuildAuth)
    }
    
    func authModuleDidCancelAuthentication() {
        isProcessing = false
        "End process authModuleDidCancelAuthentication".log()
        requestForCloseAllMozoUIs()
        stopSilentServices(shouldReconnect: false)
    }
    
    func checkToDismissAccessDeniedIfNeed() {
        if let topViewController = DisplayUtils.getTopViewController() {
            if let klass = DisplayUtils.getAuthenticationClass(), topViewController.isKind(of: klass) {
                "CorePresenter - Authentication screen is being displayed.".log()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.checkToDismissAccessDeniedIfNeed()
                }
                return
            }
            if let adViewController = topViewController as? AccessDeniedViewController {
                adViewController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func authModuleDidFinishLogout() {
        checkToDismissAccessDeniedIfNeed()
        // Send delegate back to the app
        authDelegate?.mozoLogoutDidFinish()
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        requestForCloseAllMozoUIs()
        stopSilentServices(shouldReconnect: false)
    }
    
    func authModuleDidCancelLogout() {
        isProcessing = false
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
