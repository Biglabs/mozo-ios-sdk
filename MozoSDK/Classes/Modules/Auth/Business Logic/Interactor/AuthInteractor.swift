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
    
    func extractHeaderFromLogoutRequest() {
        
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
    // MARK: Callback from URL Scheme
    func processAuthorizationCallBackUrl(_ url: URL) {
        NSLog("AuthInteractor - Process authorization callback url: \(url)")
        if authManager?.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url) ?? false {
            authManager?.setCurrentAuthorizationFlow(nil)
        } else {
            var urlString = Configuration.AUTH_ISSSUER + Configuration.BEGIN_SESSION_URL_PATH + "?redirect_uri=" + url.absoluteString
            urlString = urlString.replace("?state=", withString: "&state=")
            if let newURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                NSLog("AuthInteractor - Reprocess authorization callback url: \(newURL)")
                if authManager?.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: newURL) ?? false {
                    authManager?.setCurrentAuthorizationFlow(nil)
                }
            }
        }
    }
    
    func startRefreshTokenTimer() {
        print("AuthInteractor - Start Refresh token timer")
        authManager?.setupRefreshTokenTimer()
    }
    
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
            NSLog("AuthInteractor - Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
            _ = authManager?.codeExchange().done({ (accessToken) in
                self.output?.finishedAuthenticate(accessToken: accessToken)
                self.authManager?.setupRefreshTokenTimer()
            }).catch({ (error) in
                self.output?.errorWhileExchangeCode(error: error as? ConnectionError ?? .systemError, response: response)
            })
        } else {
            NSLog("AuthInteractor - Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
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
        }).catch({ (error) in
            let connectionError = error as? ConnectionError ?? .systemError
            self.output?.buildAuthRequestFailed(error: connectionError)
        })
    }
    
    func setCurrentAuthorizationFlow(_ authorizationFlow : OIDExternalUserAgentSession?) {
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
