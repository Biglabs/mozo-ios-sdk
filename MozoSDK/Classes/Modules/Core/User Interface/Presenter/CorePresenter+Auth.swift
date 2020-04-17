//
//  CorePresenter+Auth.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/24/19.
//

import Foundation

extension CorePresenter : AuthModuleDelegate {
    func didReceiveErrorWhileExchangingCode() {
        waitingViewInterface?.displayAlertIncorrectSystemDateTime()
    }
    
    func didCheckAuthorizationSuccess() {
        print("On Check Authorization Did Success: Download convenience data")
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        readyForGoingLive()
    }
    
    func didCheckAuthorizationFailed() {
        print("On Check Authorization Did Failed - No connection")
    }
    
    func didRemoveTokenAndLogout() {
        print("On Check Authorization Did remove token and logout")
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        stopSilentServices(shouldReconnect: false)
    }
    
    func authModuleDidFinishAuthentication(accessToken: String?) {
        isLoggingOut = false
        coreInteractor?.handleAferAuth(accessToken: accessToken)
        // Notify for all observing objects
        self.coreInteractor?.notifyAuthSuccessForAllObservers()
    }
    
    func authModuleDidFailedToMakeAuthentication(error: ConnectionError) {
        waitingViewInterface?.displayTryAgain(error, forAction: .BuildAuth)
    }
    
    func authModuleDidCancelAuthentication() {
        print("CorePresenter - Auth module did cancel authentication.")
        isLoggingOut = false
        requestForCloseAllMozoUIs()
    }
    
    func checkToDismissAccessDeniedIfNeed() {
        if let topViewController = DisplayUtils.getTopViewController() {
            if let klass = DisplayUtils.getAuthenticationClass(), topViewController.isKind(of: klass) {
                print("CorePresenter - Access denied screen is being displayed.")
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
        isLoggingOut = false
        checkToDismissAccessDeniedIfNeed()
        // Send delegate back to the app
        authDelegate?.mozoLogoutDidFinish()
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        requestForCloseAllMozoUIs()
        stopSilentServices(shouldReconnect: false)
    }
    
    func authModuleDidCancelLogout() {
        print("CorePresenter - Auth module did cancel logout.")
        isLoggingOut = false
    }
}
