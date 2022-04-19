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
    
    func handleLogoutState()
    func clearAllAuthSession()
    
    func startRefreshTokenTimer()
}

protocol AuthInteractorOutput {
    func finishedAuthenticate(accessToken: String?)
    func cancelledAuthenticateByUser()
    
    func finishLogout()
    
    func didCheckAuthorizationSuccess()
    func didRemoveTokenAndLogout()
    
    func errorWhileExchangeCode(error: ConnectionError, response: OIDAuthorizationResponse?)
}
