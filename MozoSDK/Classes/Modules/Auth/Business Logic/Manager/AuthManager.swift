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
    
    var network = MozoNetwork.TestNet
    
    var refreshTokenTimer: Timer?
    
    private (set) var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var apiManager : ApiManager? {
        didSet {
            authState = AuthDataManager.loadAuthState()
            if authState != nil {
                checkAuthorization()
            }
        }
    }
    
    // A property to store the auth state
    private (set) var authState: OIDAuthState?
    
    override init() {
        super.init()
    }
    
    func setupRefreshTokenTimer() {
        if let refreshTokenTimer = refreshTokenTimer, refreshTokenTimer.isValid {
            print("AuthManager - Refresh token timer is existing.")
            return
        }
        print("AuthManager - Setup refresh token timer.")
        let tokenExpiredAfterSeconds = network == .MainNet ? TOKEN_EXPIRE_AFTER_SECONDS_FOR_PROD : network == .DevNet ? TOKEN_EXPIRE_AFTER_SECONDS_FOR_DEV : TOKEN_EXPIRE_AFTER_SECONDS_FOR_STAG
        var fireAt = Date().addingTimeInterval(TimeInterval(tokenExpiredAfterSeconds))
        if let accessTokenExpirationDate = self.authState?.lastTokenResponse?.accessTokenExpirationDate {
            let expiresAt : Date = accessTokenExpirationDate
            fireAt = expiresAt.addingTimeInterval(TimeInterval(-tokenExpiredAfterSeconds))
        } else {
            print("Setup refresh token timer with out access token expiration date.")
        }
        print("Timer refresh token will be fire at: \(fireAt)")
        if fireAt > Date() {
            print("Setup refresh token timer, add to main run loop.")
            refreshTokenTimer = Timer(fireAt: fireAt, interval: 0, target: self, selector: #selector(fireRefreshToken), userInfo: nil, repeats: false)
            RunLoop.main.add(refreshTokenTimer!, forMode: .commonModes)
        } else {
            print("Timer refresh token won't be fire at: \(fireAt), current date: \(Date())")
//            print("Refresh token timer directly.")
//            fireRefreshToken()
        }
    }
    
    @objc func fireRefreshToken() {
        print("Fire refresh token.")
        revokeRefreshTokenTimer()
        checkRefreshToken { (success) in
            if success {
                self.setupRefreshTokenTimer()
            } else {
                
            }
        }
    }
    
    func revokeRefreshTokenTimer() {
        refreshTokenTimer?.invalidate()
        refreshTokenTimer = nil
    }
    
    func clearAll() {
        print("AuthManager - clear all: token, pin secret, user info, auth state.")
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
    
    private func checkRefreshToken(_ completion: @escaping (_ success: Bool) -> Void) {
        let expiresAt : Date = (authState?.lastTokenResponse?.accessTokenExpirationDate)!
        print("Check authorization, access token: \(authState?.lastTokenResponse?.accessToken ?? "NULL"), expires at: \(expiresAt), expires at time interval since now: \(expiresAt.timeIntervalSinceNow)")
        let tokenExpiredAfterSeconds = network == .MainNet ? TOKEN_EXPIRE_AFTER_SECONDS_FOR_PROD : TOKEN_EXPIRE_AFTER_SECONDS_FOR_DEV
        if(expiresAt.timeIntervalSinceNow < TimeInterval(tokenExpiredAfterSeconds)) {
            print("Token expired, refresh token using: \(authState?.lastTokenResponse?.refreshToken ?? "NULL")")
            authState?.setNeedsTokenRefresh()
            authState?.performAction(freshTokens: { (accessToken, ic, error) in
                if let error = error {
                    print("Did refresh token, error: \(error), ic: \(ic ?? "NULL")")
                    completion(false)
                } else {
                    print("Did refresh token, access token: \(self.authState?.lastTokenResponse?.accessToken ?? "NULL"), refresh token: \(self.authState?.lastTokenResponse?.refreshToken ?? "NULL"), expires at: \(self.authState?.lastTokenResponse?.accessTokenExpirationDate)")
                    AccessTokenManager.saveToken(self.authState?.lastTokenResponse?.accessToken)
                    AuthDataManager.saveAuthState(self.authState)
                    completion(true)
                }
            }, additionalRefreshParameters: nil)
        } else {
            completion(true)
        }
    }
    
    private func checkAuthorization(){
        print("Check authorization, try request.")
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKING
        apiManager?.checkTokenExpired().done({ (result) in
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
    
    func setCurrentAuthorizationFlow(_ authorizationFlow: OIDExternalUserAgentSession?) {
        self.currentAuthorizationFlow = authorizationFlow
    }
    
//    func handleRedirectUrl(_ url: URL) -> Bool {
//        if currentAuthorizationFlow?.resumeAuthorizationFlow(with: url) == true {
//            setCurrentAuthorizationFlow(nil)
//            return true
//        }
//        return false
//    }
    
    func buildAuthRequest() -> Promise<OIDAuthorizationRequest?> {
        return Promise { seal in
            guard let issuer = URL(string: Configuration.AUTH_ISSSUER) else {
                print("😞 Error creating URL for : \(Configuration.AUTH_ISSSUER)")
                return seal.reject(SystemError.incorrectURL)
            }
            print("Fetching configuration for issuer: \(issuer)")
            
            // discovers endpoints
            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer){ configuration, error in
                guard let config = configuration else {
                    print("😞 Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                    self.setAuthState(nil)
                    var connectionError = ConnectionError.systemError
                    if let error = error, let errorInfo = (error as NSError).userInfo["NSUnderlyingError"] as? NSError, errorInfo.domain == NSURLErrorDomain {
                        if errorInfo.code == NSURLErrorNotConnectedToInternet {
                            connectionError = ConnectionError.noInternetConnection
                        } else if errorInfo.code == NSURLErrorTimedOut {
                            connectionError = ConnectionError.requestTimedOut
                        }
                    }
                    return seal.reject(connectionError)
                }
                
                print("Got configuration: \(config)")
                
                guard let redirectURI = URL(string: Configuration.AUTH_REDIRECT_URL) else {
                    print("Error creating URL for : \(Configuration.AUTH_REDIRECT_URL)")
                    return
                }
                let param = [Configuration.AUTH_PARAM_KC_LOCALE : Configuration.LOCALE,
                             Configuration.AUTH_PARAM_APPLICATION_TYPE : Configuration.AUTH_PARAM_APPLICATION_TYPE_VALUE]
                // builds authentication request
                let request = OIDAuthorizationRequest(configuration: config,
                                                      clientId: self.clientId,
                                                      clientSecret: nil,
                                                      scopes: [OIDScopeOpenID, OIDScopeProfile],
                                                      redirectURL: redirectURI,
                                                      responseType: OIDResponseTypeCode,
                                                      additionalParameters: param)
                
                seal.fulfill(request)
            }
        }
    }
    
    func buildLogoutRequest()-> Promise<OIDAuthorizationRequest?> {
        return Promise { seal in
            guard let issuer = URL(string: Configuration.AUTH_ISSSUER) else {
                print("😞 Error creating URL for : \(Configuration.AUTH_ISSSUER)")
                return seal.reject(SystemError.incorrectURL)
            }
            print("Fetching configuration for issuer: \(issuer)")
            
            // discovers endpoints
            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer){ configuration, error in
                //https://dev.keycloak.mozocoin.io/auth/realms/mozo/protocol/openid-connect/logout?redirect_uri=https%3A%2F%2Fdev.keycloak.mozocoin.io%2Fauth%2Frealms%2Fmozo%2Fprotocol%2Fopenid-connect%2Fauth%3Fredirect_uri%3Dcom.biglabs.mozosdk.com.biglabs.mozo.example.shopper%253A%252Foauth2redirect%252Fmozo-provider%26client_id%3Dshopper_mobile_app%26response_type%3Dcode%26prompt%3Dconsent%26state%3Dam2co_gSzvHnI9og18k6TA%26nonce%3DWVxtbsRYwqJJU-mv9tZrUQ%26scope%3Dopenid%2520profile%2520phone%26code_challenge%3DGVORdp4PooXIWvUcDzBi9mrE1fm3sU3TkBBnKUVevTg%26code_challenge_method%3DS256%26kc_locale%3Dvi%26application_type%3Dnative&client_id=shopper_mobile_app&response_type=code&prompt=consent&state=am2co_gSzvHnI9og18k6TA&nonce=WVxtbsRYwqJJU-mv9tZrUQ&scope=openid%20profile%20phone&code_challenge=GVORdp4PooXIWvUcDzBi9mrE1fm3sU3TkBBnKUVevTg&code_challenge_method=S256&kc_locale=vi&application_type=native
                self.buildAuthRequest().done({ (authRequest) in
                    let authUrl = authRequest?.authorizationRequestURL()
                    guard let redirectURI = authUrl else {
                        print("Error creating URL for : \(Configuration.AUTH_REDIRECT_URL)")
                        return
                    }
                    // https://dev.keycloak.mozocoin.io/auth/realms/mozo/protocol/openid-connect/logout
                    let endSessionUrl = issuer.appendingPathComponent(Configuration.END_SESSION_URL_PATH)
                    
                    let config = OIDServiceConfiguration.init(authorizationEndpoint: endSessionUrl, tokenEndpoint: authRequest?.configuration.tokenEndpoint ?? endSessionUrl)
                    
                    let request = OIDAuthorizationRequest(configuration: config,
                                                          clientId: self.clientId,
                                                          clientSecret: nil,
                                                          scope: authRequest?.scope,
                                                          redirectURL: redirectURI,
                                                          responseType: OIDResponseTypeCode,
                                                          state: authRequest?.state,
                                                          nonce: authRequest?.nonce,
                                                          codeVerifier: authRequest?.codeVerifier,
                                                          codeChallenge: authRequest?.codeChallenge,
                                                          codeChallengeMethod: authRequest?.codeChallengeMethod,
                                                          additionalParameters: authRequest?.additionalParameters)
                    
                    seal.fulfill(request)
                }).catch({ (error) in
                    print("😞 Error creating URL for : \(Configuration.AUTH_ISSSUER)")
                    return seal.reject(SystemError.incorrectURL)
                })
            }
        }
    }
}

//MARK: AppAuth Methods
extension AuthManager {
    
    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
        
        guard let redirectURI = URL(string: Configuration.AUTH_REDIRECT_URL) else {
            print("Error creating URL for : \(Configuration.AUTH_REDIRECT_URL)")
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
        
        guard let redirectURI = URL(string: Configuration.AUTH_REDIRECT_URL) else {
            print("Error creating URL for : \(Configuration.AUTH_REDIRECT_URL)")
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
        
        guard let redirectURI = URL(string: Configuration.AUTH_REDIRECT_URL) else {
            print("Error creating URL for : \(Configuration.AUTH_REDIRECT_URL)")
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
        self.stateChanged()
    }
    
    func stateChanged() {
        AuthDataManager.saveAuthState(self.authState)
    }
    
    func codeExchange() -> Promise<String> {
        return Promise { seal in
            guard let tokenExchangeRequest = self.authState?.lastAuthorizationResponse.tokenExchangeRequest() else {
                NSLog("Error creating authorization code exchange request")
                return seal.reject(SystemError.incorrectCodeExchangeRequest)
            }
            if tokenExchangeRequest.redirectURL?.absoluteString.contains(Configuration.AUTH_ISSSUER + Configuration.BEGIN_SESSION_URL_PATH) ?? false {
                var urlString = tokenExchangeRequest.redirectURL?.absoluteString ?? ""
                let startRange = urlString.range(of: Configuration.AUTH_ISSSUER + Configuration.BEGIN_SESSION_URL_PATH)!.lowerBound
                let endRange = urlString.range(of: Configuration.AUTH_REDIRECT_URL)!.lowerBound
                let removeString = String(urlString[startRange..<endRange])
                urlString = urlString.replace(removeString, withString: "")
                let clientIdIndex = urlString.range(of: "&client_id=")!.lowerBound
                urlString = String(urlString[urlString.startIndex..<clientIdIndex])
                let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                let newRequest = OIDTokenRequest(configuration: tokenExchangeRequest.configuration, grantType: tokenExchangeRequest.grantType, authorizationCode: tokenExchangeRequest.authorizationCode, redirectURL: url!, clientID: tokenExchangeRequest.clientID, clientSecret: tokenExchangeRequest.clientSecret, scope: tokenExchangeRequest.scope, refreshToken: tokenExchangeRequest.refreshToken, codeVerifier: tokenExchangeRequest.codeVerifier, additionalParameters: tokenExchangeRequest.additionalParameters)
                NSLog("Performing authorization code exchange with request: [\(newRequest)]")
                OIDAuthorizationService.perform(newRequest){ response, error in
                    if let tokenResponse = response {
                        NSLog("Received token response with accessToken: \(tokenResponse.accessToken ?? "DEFAULT_TOKEN")")
                        seal.fulfill(tokenResponse.accessToken ?? "")
                    } else {
                        NSLog("Token exchange error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                        seal.reject(error!)
                    }
                    self.authState?.update(with: response, error: error)
                }
                return
            }
            NSLog("Performing authorization code exchange with request: [\(tokenExchangeRequest)]")
            OIDAuthorizationService.perform(tokenExchangeRequest){ response, error in
                if let tokenResponse = response {
                    NSLog("Received token response with accessToken: \(tokenResponse.accessToken ?? "DEFAULT_TOKEN")")
                    seal.fulfill(tokenResponse.accessToken ?? "")
                } else {
                    NSLog("Token exchange error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                    let networkError = error != nil ? ConnectionError.network(error: error!) : .systemError
                    seal.reject(networkError)
                }
                self.authState?.update(with: response, error: error)
            }
        }
    }
}

//MARK: OIDAuthState Delegate
extension AuthManager : OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    func didChange(_ state: OIDAuthState) {
        print("AuthState did change.")
        self.stateChanged()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
    }
}
