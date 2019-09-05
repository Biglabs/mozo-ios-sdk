//
//  ABImportModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
protocol ABImportModuleInterface {
    func loadProcessStatusForInitializing()
    func requestToImport()
    
    func stopCheckStatus()
}
