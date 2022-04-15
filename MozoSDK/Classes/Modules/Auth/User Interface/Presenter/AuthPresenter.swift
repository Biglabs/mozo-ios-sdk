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
    var authManager: AuthManager?
    
    var retryOnResponse: OIDAuthorizationResponse?
        
    func startRefreshTokenTimer() {
        authInteractor?.startRefreshTokenTimer()
    }
    
    func clearAllSessionData() {
        authInteractor?.clearAllAuthSession()
    }
    
    func processAuthorizationCallBackUrl(_ url: URL) {
        authInteractor?.processAuthorizationCallBackUrl(url)
    }
    
    @objc func applicationDidEnterBackground() {
        authInteractor?.applicationDidEnterBackground()
    }
    
    func subcribeApplicationEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}

extension AuthPresenter : AuthModuleInterface {
    func performAuthentication() {
        subcribeApplicationEvents()
        _ = self.authManager?.buildAuthRequest().done({ (request) in
            if let rq = request, let topVC = DisplayUtils.getTopViewController() {
                let flow = OIDAuthorizationService.present(rq, presenting: topVC) { (response, error) in
                    self.authModuleDelegate?.willExecuteNextStep()
                    self.authInteractor?.handleAuthorizationResponse(response, error: error)
                }
                self.authInteractor?.setCurrentAuthorizationFlow(flow)
            }
        }).catch({ (error) in
            let connectionError = error as? ConnectionError ?? .systemError
            self.buildAuthRequestFailed(error: connectionError)
        })
    }
    
    func performLogout() {
        subcribeApplicationEvents()
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
    
    func buildAuthRequestFailed(error: ConnectionError) {
        authModuleDelegate?.authModuleDidFailedToMakeAuthentication(error: error)
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
            guard let idToken = AuthDataManager.loadIdToken() else { return }
            let request = OIDEndSessionRequest(
                configuration: config,
                idTokenHint: idToken,
                postLogoutRedirectURL: redirectURI!,
                additionalParameters: nil
            )
            let viewController = DisplayUtils.getTopViewController()
            guard let userAgent = OIDExternalUserAgentIOS(presenting: viewController!) else { return }
            
            
            // performs logout request
            let currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: userAgent) { (response, error) in
                if error == nil {
                    "AuthPresenter - Logout success".log()
                    self.authInteractor?.clearAllAuthSession()
                    self.authModuleDelegate?.authModuleDidFinishLogout {
                        self.authModuleDelegate?.willExecuteNextStep()
                        self.authModuleDelegate?.willRelaunchAuthentication()
                    }
                } else {
                    "AuthPresenter - Logout failed".log()
                    self.authModuleDelegate?.authModuleDidCancelLogout()
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
        self.cancelledAuthenticateByUser()
    }
}
