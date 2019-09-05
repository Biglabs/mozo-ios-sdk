//
//  ABImportInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
protocol ABImportInteractorInput {
    func startWaitingForImporting()
    func stopWaitingForImporting()
    func loadProcessStatusForInitializing()
    func requestImportWithContacts(_ contacts: [ContactInfoDTO])
}
protocol ABImportInteractorOutput {
    func didReceiveProcessStatus(_ processStatus: AddressBookImportProcessDTO, forInitializing: Bool)
    func errorWhileLoadingProcessStatus(error: ConnectionError, forInitializing: Bool)
    
    func didRequestImportSuccess()
    func errorWhileRequestingImport(error: ConnectionError)
}
