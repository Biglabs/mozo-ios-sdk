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
        isAuthenticating = false
        coreInteractor?.handleAferAuth(accessToken: accessToken)
        // Notify for all observing objects
        self.coreInteractor?.notifyAuthSuccessForAllObservers()
    }
    
    func authModuleDidFailedToMakeAuthentication(error: ConnectionError) {
        waitingViewInterface?.displayTryAgain(error, forAction: .BuildAuth)
    }
    
    func authModuleDidCancelAuthentication() {
        isAuthenticating = false
        requestForCloseAllMozoUIs()
    }
    
    func authModuleDidFinishLogout() {
        // Send delegate back to the app
        authDelegate?.mozoLogoutDidFinish()
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        requestForCloseAllMozoUIs()
        stopSilentServices(shouldReconnect: false)
    }
    
    func authModuleDidCancelLogout() {
        
    }
}
