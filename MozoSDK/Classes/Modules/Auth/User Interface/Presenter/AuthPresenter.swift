//
//  AuthPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation
import AppAuth

class AuthPresenter : NSObject {
    var authInteractor : AuthInteractorInput?
    var authModuleDelegate : AuthModuleDelegate?
    var authManager: AuthManager?
    
    var retryOnResponse: OIDAuthorizationResponse?
        
    func startRefreshTokenTimer() {
        authInteractor?.startRefreshTokenTimer()
    }
    
    func clearAllSessionData() {
        authInteractor?.clearAllAuthSession()
    }
}

extension AuthPresenter : AuthModuleInterface {
    func performAuthentication() {
        if let topVC = DisplayUtils.getTopViewController() {
            AuthWebVC.signIn(topVC)
        } else {
            self.authModuleDelegate?.authModuleDidCancelAuthentication()
        }
    }
    
    func performLogout() {
        clearAllSessionData()
        authModuleDelegate?.authModuleDidFinishLogout {
            if let topVC = DisplayUtils.getTopViewController() {
                AuthWebVC.signOut(topVC)
            } else {
                self.authModuleDelegate?.authModuleDidCancelAuthentication()
            }
        }
    }
}

extension AuthPresenter : AuthInteractorOutput {
    func errorWhileExchangeCode(error: ConnectionError, response: OIDAuthorizationResponse?) {
        if error == .authenticationRequired {
            NSLog("AuthPresenter - Error related to authentication while exchange code, need re-authenticate.")
            let viewController = DisplayUtils.getTopViewController() as? MozoBasicViewController
            viewController?.displayMozoError("Error related to authentication while exchange code.\nPlease re-authenticate.")
            return
        }
        if error == .incorrectSystemDateTime {
            NSLog("AuthPresenter - Incorrect system date time while exchanging code. Go to Settings.")
            authModuleDelegate?.didReceiveErrorWhileExchangingCode()
            return
        }
        retryOnResponse = response
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, isEmbedded: false, error: error, delegate: self)
    }
    
    func didCheckAuthorizationSuccess() {
        authModuleDelegate?.didCheckAuthorizationSuccess()
    }
    
    func didRemoveTokenAndLogout() {
        authModuleDelegate?.didRemoveTokenAndLogout()
    }
    
    func finishedAuthenticate(accessToken: String?) {
        retryOnResponse = nil
        authModuleDelegate?.authModuleDidFinishAuthentication(accessToken: accessToken)
        NotificationCenter.default.removeObserver(self)
    }
    
    func cancelledAuthenticateByUser() {
        retryOnResponse = nil
        authModuleDelegate?.authModuleDidCancelAuthentication()
        NotificationCenter.default.removeObserver(self)
    }
    
    func finishLogout() {
        
    }
}
extension AuthPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
    }
    
    func didClosePopupWithoutRetry() {
        self.cancelledAuthenticateByUser()
    }
}
