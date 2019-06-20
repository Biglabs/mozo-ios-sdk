//
//  ChangePINModuleDelegate.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
protocol ChangePINModuleDelegate {
    func verifiedCurrentPINSuccess(_ pin: String)
    func inputNewPINSuccess(_ pin: String)
}
