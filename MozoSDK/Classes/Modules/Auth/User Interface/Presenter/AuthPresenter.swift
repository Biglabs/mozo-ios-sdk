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
        let viewController = authWireframe?.getTopViewController()
        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: viewController!) { (response, error) in
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
        let viewController = authWireframe?.getTopViewController()
        // performs logout request
        print("Initiating logout request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: viewController!) { (response, error) in
            print("Finish present logout, error: [\(error)]")
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
