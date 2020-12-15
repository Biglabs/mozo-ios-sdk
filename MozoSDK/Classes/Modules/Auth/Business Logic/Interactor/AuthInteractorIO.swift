//
//  AuthInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation
import AppAuth

protocol AuthInteractorInput {
    func updateClientId(_ appType: AppType)
    func updateNetwork(_ network: MozoNetwork)
    
    func buildAuthRequest()
    func setCurrentAuthorizationFlow(_ authorizationFlow : OIDExternalUserAgentSession?)
    func handleAuthorizationResponse(_ response: OIDAuthorizationResponse?, error: Error?)
    
    func buildLogoutRequest()
    func handleLogoutState()
    func clearAllAuthSession()
    
    func startRefreshTokenTimer()
    
    func processAuthorizationCallBackUrl(_ url: URL)
    func applicationDidEnterBackground()
}

protocol AuthInteractorOutput {
    func finishedBuildAuthRequest(_ request: OIDAuthorizationRequest)
    func buildAuthRequestFailed(error: ConnectionError)
    func finishedAuthenticate(accessToken: String?)
    func cancelledAuthenticateByUser()
    
    func finishBuildLogoutRequest()
    func finishLogout()
    
    func didCheckAuthorizationSuccess()
    func didRemoveTokenAndLogout()
    
    func errorWhileExchangeCode(error: ConnectionError, response: OIDAuthorizationResponse?)
}
