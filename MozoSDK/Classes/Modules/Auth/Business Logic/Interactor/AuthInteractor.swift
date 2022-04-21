//
//  AuthInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation

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
    func startRefreshTokenTimer() {
        "AuthInteractor - Start Refresh token timer".log()
        authManager?.setupRefreshTokenTimer()
    }
    
    func clearAllAuthSession() {
        authManager?.clearAll()
    }
    
    func handleLogoutState() {
    }
}
