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
    func errorWhileExchangeCode(error: ConnectionError, response: OIDAuthorizationResponse?) {
        if error == .authenticationRequired {
            NSLog("AuthPresenter - Error related to authentication while exchange code, need re-authenticate.")
            let viewController = DisplayUtils.getTopViewController() as? MozoBasicViewController
            viewController?.displayMozoError("Error related to authentication while exchange code.\nPlease re-authenticate.")
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
        // performs authentication request
        NSLog("AuthPresenter - Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let viewController = authWireframe?.getTopViewController()
        // performs authentication request
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: viewController!) { (response, error) in
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
    
    func finishBuildLogoutRequest(_ request: OIDAuthorizationRequest) {
        // performs logout request
        NSLog("AuthPresenter - Initiating logout request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let viewController = authWireframe?.getTopViewController()
        // performs logout request
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: viewController!) { (response, error) in
            print("AuthPresenter - Finish present logout, error: [\(String(describing: error))]")
            if error == nil {
                // Must waiting for AppAuth WebViewController display.
                self.authInteractor?.clearAllAuthSession()
                self.authModuleDelegate?.authModuleDidFinishLogout()
            }
        }
        authInteractor?.setCurrentAuthorizationFlow(currentAuthorizationFlow)
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
