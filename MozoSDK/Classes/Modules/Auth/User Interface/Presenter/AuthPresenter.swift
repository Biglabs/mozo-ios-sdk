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
        authInteractor?.buildLogoutRequest()
    }
}

extension AuthPresenter : AuthInteractorOutput {
    func didCheckAuthorizationSuccess() {
        authModuleDelegate?.didCheckAuthorizationSuccess()
    }
    
    func didRemoveTokenAndLogout() {
        authModuleDelegate?.didRemoveTokenAndLogout()
    }
    
    func finishedBuildAuthRequest(_ request: OIDAuthorizationRequest) {
        // performs authentication request
        NSLog("AuthPresenter - Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let userAgent = OIDExternalUserAgentIOSCustomBrowser.customBrowserSafari()
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: userAgent) { (response, error) in
            self.authInteractor?.handleAuthorizationResponse(response, error: error)
        }
        authInteractor?.setCurrentAuthorizationFlow(currentAuthorizationFlow)
    }
    
    func buildAuthRequestFailed(error: ConnectionError) {
        authModuleDelegate?.authModuleDidFailedToMakeAuthentication(error: error)
    }
    
    func finishedAuthenticate(accessToken: String?) {
        authModuleDelegate?.authModuleDidFinishAuthentication(accessToken: accessToken)
    }
    
    func cancelledAuthenticateByUser() {
        authModuleDelegate?.authModuleDidCancelAuthentication()
    }
    
    func finishBuildLogoutRequest(_ request: OIDAuthorizationRequest) {
        // performs logout request
        NSLog("AuthPresenter - Initiating logout request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        self.logoutWillBePerformed()
        let userAgent = OIDExternalUserAgentIOSCustomBrowser.customBrowserSafari()
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: userAgent) { (response, error) in
            NSLog("AuthPresenter - Finish present logout then login automatically, error: [\(String(describing: error))]")
            self.authInteractor?.handleAuthorizationResponse(response, error: error)
        }
        authInteractor?.setCurrentAuthorizationFlow(currentAuthorizationFlow)
    }
    
    func finishLogout() {
        
    }
}
