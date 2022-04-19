//
//  AuthManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation
import AppAuth
import PromiseKit

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void
let TOKEN_EXPIRE_AFTER_SECONDS_FOR_PROD = 2 * 24 * 3600
let TOKEN_EXPIRE_AFTER_SECONDS_FOR_DEV = 5 * 60
let TOKEN_EXPIRE_AFTER_SECONDS_FOR_STAG = 1 * 60
class AuthManager : NSObject {
    var delegate : AuthManagerDelegate?
    
    var clientId = Configuration.AUTH_SHOPPER_CLIENT_ID
    
    var refreshTokenTimer: Timer?
    
    // A property to store the auth state
    private (set) var authState: OIDAuthState?
    
    override init() {
        super.init()
        self.reportToken()
        self.checkAuthorization()
    }
    
    func setupRefreshTokenTimer() {
        if let refreshTokenTimer = refreshTokenTimer, refreshTokenTimer.isValid {
            "AuthManager - Refresh token timer is existing.".log()
            return
        }
        "AuthManager - Setup refresh token timer.".log()
        let tokenExpiredAfterSeconds = MozoSDK.network == .MainNet ? TOKEN_EXPIRE_AFTER_SECONDS_FOR_PROD : MozoSDK.network == .DevNet ? TOKEN_EXPIRE_AFTER_SECONDS_FOR_DEV : TOKEN_EXPIRE_AFTER_SECONDS_FOR_STAG
        var fireAt = Date()
        if let accessTokenExpirationDate = self.authState?.lastTokenResponse?.accessTokenExpirationDate {
            "Token Expiration Time: \(accessTokenExpirationDate.description(with: .current))".log()
            fireAt = accessTokenExpirationDate
        }
        fireAt = fireAt.addingTimeInterval(TimeInterval(-tokenExpiredAfterSeconds))
        "Refresh token will be fire at: \(fireAt.description(with: .current))".log()
        
        if fireAt > Date() {
            refreshTokenTimer = Timer(fireAt: fireAt, interval: 0, target: self, selector: #selector(fireRefreshToken), userInfo: nil, repeats: false)
            RunLoop.main.add(refreshTokenTimer!, forMode: RunLoop.Mode.common)
        } else {
            fireRefreshToken()
        }
    }
    
    @objc func fireRefreshToken() {
        "Fire refresh token.".log()
        revokeRefreshTokenTimer()
        checkRefreshToken { (success) in
            if success {
                self.setupRefreshTokenTimer()
            } else {
                self.revokeRefreshTokenTimer()
                self.delegate?.didRemoveTokenAndLogout()
            }
        }
    }
    
    func revokeRefreshTokenTimer() {
        refreshTokenTimer?.invalidate()
        refreshTokenTimer = nil
    }
    
    func clearAll() {
        "AuthManager - clear all: token, pin secret, user info, auth state.".log()
        AccessTokenManager.clearToken()
        AccessTokenManager.clearPinSecret()
        SessionStoreManager.clearCurrentUser()
        SafetyDataManager.shared.offchainDetailDisplayData = nil
        SafetyDataManager.shared.onchainFromOffchainDetailDisplayData = nil
        SafetyDataManager.shared.ethDetailDisplayData = nil
        SafetyDataManager.shared.onchainDetailDisplayData = nil
        setAuthState(nil)
        revokeRefreshTokenTimer()
    }
    
    func reportToken() {
        if let token = AccessTokenManager.getAccessToken(), !token.isEmpty {
            _ = ApiManager.shared.reportToken(token)
        }
    }
    
    private func checkRefreshToken(_ completion: @escaping (_ success: Bool) -> Void) {
        let expiresAt : Date = authState?.lastTokenResponse?.accessTokenExpirationDate ?? Date()
        "Check authorization, access token: \(authState?.lastTokenResponse?.accessToken ?? "NULL") \nexpires at: \(expiresAt), expires at time interval since now: \(expiresAt.timeIntervalSinceNow)".log()
        let tokenExpiredAfterSeconds = MozoSDK.network == .MainNet ? TOKEN_EXPIRE_AFTER_SECONDS_FOR_PROD : TOKEN_EXPIRE_AFTER_SECONDS_FOR_DEV
        if(expiresAt.timeIntervalSinceNow < TimeInterval(tokenExpiredAfterSeconds)) {
            authState?.setNeedsTokenRefresh()
            authState?.performAction(freshTokens: { (accessToken, ic, error) in
                if let error = error {
                    "Did refresh token, error: \(error), ic: \(ic ?? "NULL")".log()
                    completion(false)
                } else {
                    "Did refresh token, access token: \(self.authState?.lastTokenResponse?.accessToken ?? "NULL") \nrefresh token: \(self.authState?.lastTokenResponse?.refreshToken ?? "NULL") \nexpires at: \(String(describing: self.authState?.lastTokenResponse?.accessTokenExpirationDate))".log()
                    AccessTokenManager.saveToken(self.authState?.lastTokenResponse?.accessToken)
                    //MARK: todo AccessTokenManager.save(<#T##token: AccessToken?##AccessToken?#>)
                    self.reportToken()
                    completion(true)
                }
            }, additionalRefreshParameters: nil)
        } else {
            completion(true)
        }
    }
    
    private func checkAuthorization() {
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKING
        ApiManager.shared.checkTokenExpired().done({ (result) in
            print("Did check token expired success.")
            self.delegate?.didCheckAuthorizationSuccess()
            // TODO: Reload user info in case error with user info at the latest login
            // Remember: Authen flow and wallet flow might be affected by reloading here
            self.checkRefreshToken {_ in }
        }).catch({ (err) in
            let error = err as! ConnectionError
            if error == ConnectionError.authenticationRequired {
                print("Token expired, clear token and user info")
                if let expiresAt = self.authState?.lastTokenResponse?.accessTokenExpirationDate {
                    print("Expires at: \(expiresAt)")
                }
                self.clearAll()
                self.delegate?.didRemoveTokenAndLogout()
            } else {
                self.checkRefreshToken({ (success) in
                    if success {
                        self.delegate?.didCheckAuthorizationSuccess()
                    } else {
                        self.clearAll()
                        self.delegate?.didRemoveTokenAndLogout()
                    }
                })
            }
        })
    }
}

//MARK: AppAuth Methods
extension AuthManager {
    
    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
        
        guard let redirectURI = URL(string: Configuration.authRedirectURL()) else {
            print("Error creating URL for : \(Configuration.authRedirectURL())")
            return
        }
        
        let request: OIDRegistrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                                     redirectURIs: [redirectURI],
                                                                     responseTypes: nil,
                                                                     grantTypes: nil,
                                                                     subjectType: nil,
                                                                     tokenEndpointAuthMethod: "client_secret_post",
                                                                     additionalParameters: nil)
        
        // performs registration request
        print("Initiating registration request")
        
        OIDAuthorizationService.perform(request) { response, error in
            
            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                print("Got registration response: \(regResponse)")
                callback(configuration, regResponse)
            } else {
                print("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        guard let redirectURI = URL(string: Configuration.authRedirectURL()) else {
            print("Error creating URL for : \(Configuration.authRedirectURL())")
            return
        }
        
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        
        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
    }
    
    func doAuthWithoutCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        guard let redirectURI = URL(string: Configuration.authRedirectURL()) else {
            print("Error creating URL for : \(Configuration.authRedirectURL())")
            return
        }
        
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        
        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
    }
}

//MARK: Helper Methods
extension AuthManager {
    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return
        }
        self.authState = authState
        self.authState?.stateChangeDelegate = self
    }
}

//MARK: OIDAuthState Delegate
extension AuthManager : OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    func didChange(_ state: OIDAuthState) {
        print("AuthState did change.")
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
    }
}
