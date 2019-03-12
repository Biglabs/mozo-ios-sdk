//
//  ConfirmConvertViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
protocol ConfirmConvertViewInterface {
    func displayError(_ error: String)
    func displaySpinner()
    func removeSpinner()
}
