//
//  MaintenancePresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
class MaintenancePresenter: NSObject {
    var interactor: MaintenanceInteractor?
    var viewInterface: MaintenanceViewInterface?
    
    override init() {
        super.init()
        interactor = MaintenanceInteractor()
        interactor?.output = self
    }
    
    func openReadMore(item: FAQDisplayItem) {
        guard let url = URL(string: "\(Configuration.LANDING_PAGE_URL)\(item.link)") else { return }
        print("MaintenancePresenter - OpenReadMore with url [\(url)]")
        UIApplication.shared.open(url)
    }
    
    func startWaiting() {
        NSLog("MaintenancePresenter - Start waiting")
        interactor?.startWaitingMaintenanceStatus()
    }
}
extension MaintenancePresenter: MaintenanceInteractorOutput {
    func didReceiveMaintenanceStatus(_ status: MaintenanceStatusType) {
        if status == .HEALTHY {
            viewInterface?.dismissMaintenance()
        }
    }
    
    func didReceiveError(error: ConnectionError) {
        
    }
}
