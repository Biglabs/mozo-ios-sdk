//
//  AuthManagerDelegate.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/25/18.
//

import Foundation

@objc protocol AuthManagerDelegate {
    func didCheckAuthorizationSuccess()
    func didRemoveTokenAndLogout()
    @objc optional func didCheckAuthorizationFailed()
}
