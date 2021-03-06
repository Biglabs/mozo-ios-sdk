//
//  TransferViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/19/18.
//

import Foundation

protocol TransferViewInterface {
    func updateUserInterfaceWithTokenInfo(_ tokenInfo: TokenInfoDTO)
    func updateUserInterfaceWithAddress(_ address: String)
    func displayError(_ error: String)
    
    func updateInterfaceWithDisplayItem(_ displayItem: AddressBookDisplayItem)
    func notFoundContact(_ phoneNo: String)
    
    func showErrorValidation(_ error: String?, isAddress: Bool)
    func hideErrorValidation()
    func displayTryAgain(_ error: ConnectionError)
    
    func displaySpinner()
    func removeSpinner()
}
