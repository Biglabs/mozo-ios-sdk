//
//  ABEditViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation

protocol ABEditViewInterface {
    func displaySpinner()
    func removeSpinner()
    func displaySuccess()
    func displayTryAgain(_ error: ConnectionError, forDelete: Bool)
}
