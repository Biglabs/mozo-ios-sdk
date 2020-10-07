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
    
//    var logoutQueue = DispatchQueue(label: "logoutQueue", attributes: .concurrent)
        
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
        // TODO: Avoid race condition here using logout queue
//        logoutQueue.async(flags: .barrier) {
//        }
        //if !isLoggingOut {
            isLoggingOut = true
            clearAllSessionData()
            authInteractor?.buildLogoutRequest()
        //}
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
        // FIX ME: Figure out why we crash here
        // performs authentication request
        NSLog("AuthPresenter - Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let viewController = DisplayUtils.getTopViewController()
        
        if let authViewController = viewController,
            let klass = DisplayUtils.getAuthenticationClass(),
            authViewController.isKind(of: klass) {
            print("AuthPresenter - Authentication screen is being displayed.")
            return
        }
        NSLog("AuthPresenter - Top view controller [\(String(describing: viewController.self))] will be used to perform authentication request.")
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
        NSLog("AuthPresenter - Cancelled authenticate by user")
        authModuleDelegate?.authModuleDidCancelAuthentication()
    }
    
    func finishBuildLogoutRequest(_ request: OIDAuthorizationRequest) {
        // performs logout request
        NSLog("AuthPresenter - Initiating logout request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let viewController = DisplayUtils.getTopViewController()
        // performs logout request
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: viewController!) { (response, error) in
            print("AuthPresenter - Finish present logout, error: [\(String(describing: error))]")
            self.isLoggingOut = false
            if error != nil {
                self.authModuleDelegate?.authModuleDidCancelLogout()
            } else {
                // TODO: Must wait for AppAuth WebViewController display.
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
