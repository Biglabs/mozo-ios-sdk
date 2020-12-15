//
//  AuthWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation

class AuthWireframe: MozoWireframe {
    var authPresenter : AuthPresenter?
    
    func presentInitialAuthInterface() {
        authPresenter?.performAuthentication()
    }
    
    func presentLogoutInterface() {
        authPresenter?.performLogout()
    }
    
    func startRefreshTokenTimer() {
        authPresenter?.startRefreshTokenTimer()
    }
    
    func clearAllSessionData() {
        authPresenter?.clearAllSessionData()
    }
    
    func processAuthorizationCallBackUrl(_ url: URL) {
        authPresenter?.processAuthorizationCallBackUrl(url)
    }
}
