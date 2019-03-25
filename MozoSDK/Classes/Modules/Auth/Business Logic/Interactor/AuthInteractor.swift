//
//  AuthInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation
import AppAuth

class AuthInteractor : NSObject {
    var output : AuthInteractorOutput?
    
    var authManager: AuthManager?
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        super.init()
        self.authManager?.delegate = self
    }
}
extension AuthInteractor: AuthManagerDelegate {
    func didCheckAuthorizationSuccess() {
        output?.didCheckAuthorizationSuccess()
    }
    
    func didRemoveTokenAndLogout() {
        output?.didRemoveTokenAndLogout()
    }
}
extension AuthInteractor : AuthInteractorInput {
    func updateClientId(_ appType: AppType) {
        self.authManager?.clientId = appType == .Retailer ? Configuration.AUTH_RETAILER_CLIENT_ID : Configuration.AUTH_SHOPPER_CLIENT_ID
    }
    
    func updateNetwork(_ network: MozoNetwork) {
        self.authManager?.network = network
    }
    
    func handleAuthorizationResponse(_ response: OIDAuthorizationResponse?, error: Error?) {
        if let response = response {
            let authState = OIDAuthState(authorizationResponse: response)
            authManager?.setAuthState(authState)
            authManager?.setupRefreshTokenTimer()
            print("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
            _ = authManager?.codeExchange().done({ (accessToken) in
                self.output?.finishedAuthenticate(accessToken: accessToken)
            })
        } else {
            print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
            output?.cancelledAuthenticateByUser()
        }
    }
    
    func clearAllAuthSession() {
        authManager?.clearAll()
    }
    
    func buildAuthRequest() {
        _ = authManager?.buildAuthRequest().done({ (request) in
            if let rq = request {
                self.output?.finishedBuildAuthRequest(rq)
            }
        })
    }
    
    func setCurrentAuthorizationFlow(_ authorizationFlow : OIDAuthorizationFlowSession?) {
        authManager?.setCurrentAuthorizationFlow(authorizationFlow)
    }
    
    func buildLogoutRequest() {
        _ = authManager?.buildLogoutRequest().done({ (request) in
            if let rq = request {
                self.output?.finishBuildLogoutRequest(rq)
            }
        })
    }
    
    func handleLogoutState() {

    }
}
