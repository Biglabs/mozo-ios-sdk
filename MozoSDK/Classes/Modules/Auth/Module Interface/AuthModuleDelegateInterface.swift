//
//  AuthModuleDelegateInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/12/18.
//

import Foundation

protocol AuthModuleDelegate {
    func authModuleDidFinishAuthentication(accessToken: String?)
    func authModuleDidFailedToMakeAuthentication(error: ConnectionError)
    func authModuleDidCancelAuthentication()
    func authModuleDidFinishLogout()
    func authModuleDidCancelLogout()
    
    func didCheckAuthorizationSuccess()
    func didCheckAuthorizationFailed()
    func didRemoveTokenAndLogout()
    
    func didReceiveErrorWhileExchangingCode()
    
    func willExecuteNextStep()
    func willRelaunchAuthentication()
}
