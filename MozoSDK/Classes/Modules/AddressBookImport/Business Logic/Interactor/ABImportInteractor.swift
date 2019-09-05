//
//  ABImportInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
class ABImportInteractor: NSObject {
    var apiManager : ApiManager?
    var output: ABImportInteractorOutput?
    
    var txStatusTimer: Timer?
    var isWaiting = false
    
    func startWaitingStatusService() {
        if isWaiting {
            return
        }
        isWaiting = true
        NSLog("ABImportInteractor - Start waiting status service")
        txStatusTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadImportStatus), userInfo: nil, repeats: true)
    }
    
    func stopService() {
        isWaiting = false
        NSLog("ABImportInteractor - Stop waiting status service")
        txStatusTimer?.invalidate()
    }
    
    @objc func loadImportStatus(forInitializing: Bool = false) {
        _ = apiManager?.checkProcessImportContact().done({ (result) in
            self.output?.didReceiveProcessStatus(result, forInitializing: forInitializing)
        }).catch({ (error) in
            self.output?.errorWhileLoadingProcessStatus(error: error as? ConnectionError ?? .systemError, forInitializing: forInitializing)
        })
    }
}
extension ABImportInteractor : ABImportInteractorInput {
    func startWaitingForImporting() {
        startWaitingStatusService()
    }
    
    func stopWaitingForImporting() {
        stopService()
    }
    
    func loadProcessStatusForInitializing() {
        loadImportStatus(forInitializing: true)
    }
    
    func requestImportWithContacts(_ contacts: [ContactInfoDTO]) {
        let contactInfo = ImportContactInfoDTO(contactInfos: contacts)
        _ = apiManager?.importContacts(contactInfo).done({ (result) in
            self.output?.didRequestImportSuccess()
        }).catch({ (error) in
            self.output?.errorWhileRequestingImport(error: error as? ConnectionError ?? .systemError)
        })
    }
}
