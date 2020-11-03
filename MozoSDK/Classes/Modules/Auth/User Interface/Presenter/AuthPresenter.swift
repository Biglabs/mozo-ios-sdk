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
    var authWireframe : AuthWireframe?
    var authModuleDelegate : AuthModuleDelegate?
    
    var retryOnResponse: OIDAuthorizationResponse?
    
    var isLoggingOut = false
    
    func startRefreshTokenTimer() {
        authInteractor?.startRefreshTokenTimer()
    }
    
    func clearAllSessionData() {
        authInteractor?.clearAllAuthSession()
    }
    
    func processAuthorizationCallBackUrl(_ url: URL) {
        authInteractor?.processAuthorizationCallBackUrl(url)
    }
    
    func logoutWillBePerformed() {
        NSLog("AuthPresenter - Logout will be performed")
        self.authInteractor?.clearAllAuthSession()
        self.authModuleDelegate?.authModuleDidFinishLogout()
    }
}

extension AuthPresenter : AuthModuleInterface {
    func performAuthentication() {
        authInteractor?.buildAuthRequest()
    }
    
    func performLogout() {
        if !isLoggingOut {
            isLoggingOut = true
            clearAllSessionData()
            authInteractor?.buildLogoutRequest()
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
    
    func finishedBuildAuthRequest(_ request: OIDAuthorizationRequest) {
        let viewController = DisplayUtils.getTopViewController()
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: viewController!) { (response, error) in
            self.authModuleDelegate?.willHandleAuthResponse()
            self.authInteractor?.handleAuthorizationResponse(response, error: error)
        }
        authInteractor?.setCurrentAuthorizationFlow(currentAuthorizationFlow)
    }
    
    func buildAuthRequestFailed(error: ConnectionError) {
        authModuleDelegate?.authModuleDidFailedToMakeAuthentication(error: error)
    }
    
    func finishedAuthenticate(accessToken: String?) {
        retryOnResponse = nil
        authModuleDelegate?.authModuleDidFinishAuthentication(accessToken: accessToken)
    }
    
    func cancelledAuthenticateByUser() {
        authModuleDelegate?.authModuleDidCancelAuthentication()
    }
    
    func finishBuildLogoutRequest() {
        let issuer = URL(string: Configuration.AUTH_ISSSUER)
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer!) { configuration, error in
            let redirectURI = URL(string: Configuration.authRedirectURL())
            guard let idToken = AuthDataManager.loadIdToken() else { return }
            let request = OIDEndSessionRequest(
                configuration: configuration!,
                idTokenHint: idToken,
                postLogoutRedirectURL: redirectURI!,
                additionalParameters: nil
            )
            let viewController = DisplayUtils.getTopViewController()
            guard let userAgent = OIDExternalUserAgentIOS(presenting: viewController!) else { return }
            
            
            // performs logout request
            let currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: userAgent) { (response, error) in
                self.isLoggingOut = false
                if error != nil {
                    self.authModuleDelegate?.authModuleDidCancelLogout()
                } else {
                    // TODO: Must wait for AppAuth WebViewController display.
                    self.authInteractor?.clearAllAuthSession()
                    self.authModuleDelegate?.authModuleDidFinishLogout()
                    self.authModuleDelegate?.willHandleAuthResponse()
                    
                    /**
                     Re-call Sign In
                     */
                    MozoSDK.authenticate()
                }
            }
            self.authInteractor?.setCurrentAuthorizationFlow(currentAuthorizationFlow)
        }
    }
    
    func finishLogout() {
        
    }
}
extension AuthPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        if let response = self.retryOnResponse {
            self.authInteractor?.handleAuthorizationResponse(response, error: nil)
        }
    }
    
    func didClosePopupWithoutRetry() {
        retryOnResponse = nil
    }
}
