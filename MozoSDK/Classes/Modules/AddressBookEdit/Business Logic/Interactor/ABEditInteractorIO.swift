//
//  ABEditInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation
protocol ABEditInteractorInput {
    func updateAddressBook(_ addressBook: AddressBookDisplayItem)
    func deleteAddressBook(_ addressBook: AddressBookDisplayItem)
}

protocol ABEditInteractorOutput {
    func finishUpdate()
    func finishDelete()
    func didReceiveError(_ error: ConnectionError, forDelete: Bool)
}
