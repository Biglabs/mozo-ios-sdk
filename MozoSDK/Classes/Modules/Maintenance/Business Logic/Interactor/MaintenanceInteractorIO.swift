//
//  MaintenanceInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/15/19.
//

import Foundation
protocol MaintenanceInteractorInput {
    func startWaitingMaintenanceStatus()
    func stopService()
}
protocol MaintenanceInteractorOutput {
    func didReceiveMaintenanceStatus(_ status: MaintenanceStatusType)
    func didReceiveError(error: ConnectionError)
}
