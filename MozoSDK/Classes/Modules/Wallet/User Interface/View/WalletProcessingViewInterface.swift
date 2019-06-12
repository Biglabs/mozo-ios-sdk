//
//  WalletProcessingViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
protocol WalletProcessingViewInterface {
    func displayError(_ error: String)    
    func displayErrorAndLogout(_ error: ErrorApiResponse)
}
