//
//  ABImportViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
protocol ABImportViewInterface {
    func displaySpinner()
    func removeSpinner()
    func showSettingPermissionAlert()
    
    func updateInterfaceWithProcessStatus(_ processStatus: AddressBookImportProcessDTO)
}
