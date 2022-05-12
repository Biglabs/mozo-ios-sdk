//
//  AuthPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation

class AuthPresenter : NSObject {
    var authInteractor : AuthInteractorInput?
    var authModuleDelegate : AuthModuleDelegate?
    var authManager: AuthManager?
        
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
    func errorWhileExchangeCode(error: ConnectionError) {
        if error == .authenticationRequired {
            let viewController = DisplayUtils.getTopViewController() as? MozoBasicViewController
            viewController?.displayMozoError("Error related to authentication while exchange code.\nPlease re-authenticate.")
            return
        }
        if error == .incorrectSystemDateTime {
            authModuleDelegate?.didReceiveErrorWhileExchangingCode()
            return
        }
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, isEmbedded: false, error: error, delegate: self)
    }
    
    func didCheckAuthorizationSuccess() {
        authModuleDelegate?.didCheckAuthorizationSuccess()
    }
    
    func didRemoveTokenAndLogout() {
        authModuleDelegate?.didRemoveTokenAndLogout()
    }
    
    func finishedAuthenticate(accessToken: String?) {
        authModuleDelegate?.authModuleDidFinishAuthentication(accessToken: accessToken)
        NotificationCenter.default.removeObserver(self)
    }
    
    func cancelledAuthenticateByUser() {
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
