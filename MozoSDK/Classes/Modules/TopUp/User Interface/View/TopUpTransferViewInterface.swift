//
//  TopUpTransferViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/19.
//

import Foundation
protocol TopUpTransferViewInterface {
    func updateUserInterfaceWithTokenInfo(_ tokenInfo: TokenInfoDTO)
    
    func displayError(_ error: String)
        
    func showErrorValidation(_ error: String)
    func hideErrorValidation()
    
    func displaySpinner()
    func removeSpinner()
}
