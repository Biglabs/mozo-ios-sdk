//
//  ABSupportInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/6/19.
//

import Foundation
protocol ABSupportInteractorInput {
    func findContact(_ phoneNo: String)
}
protocol ABSupportInteractorOutput {
    func didFindContact(_ addressBook: AddressBookDisplayItem)
    func contactNotFound(_ phoneNo: String)
    func errorWhileFindingContact(_ phoneNo: String, error: ConnectionError)
}
