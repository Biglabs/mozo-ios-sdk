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
            AuthWebVC.launch(topVC)
        } else {
            self.authModuleDelegate?.authModuleDidCancelAuthentication()
        }
    }
    
    func performLogout() {
        clearAllSessionData()
        authModuleDelegate?.authModuleDidFinishLogout {
            self.authInteractor?.buildLogoutRequest()
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
    
    func finishBuildLogoutRequest() {
        let issuer = URL(string: Configuration.AUTH_ISSSUER)
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer!) { configuration, error in
            guard let config = configuration else {
                self.authModuleDelegate?.authModuleDidCancelLogout()
                return
            }
            
            let redirectURI = URL(string: Configuration.authRedirectURL())
            guard let idToken = AccessTokenManager.load()?.idToken else { return }
            let request = OIDEndSessionRequest(
                configuration: config,
                idTokenHint: idToken,
                postLogoutRedirectURL: redirectURI!,
                additionalParameters: nil
            )
            let viewController = DisplayUtils.getTopViewController()
            guard let userAgent = OIDExternalUserAgentIOS(presenting: viewController!) else { return }
            
            
            // performs logout request
            OIDAuthorizationService.present(request, externalUserAgent: userAgent) { (response, error) in
                if error == nil {
                    "AuthPresenter - Logout success".log()
                    self.authInteractor?.clearAllAuthSession()
                    self.authModuleDelegate?.authModuleDidFinishLogout {
                        self.authModuleDelegate?.willRelaunchAuthentication()
                    }
                } else {
                    "AuthPresenter - Logout failed".log()
                    self.authModuleDelegate?.authModuleDidCancelLogout()
                }
            }
        }
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
