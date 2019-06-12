//
//  ChangePINInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINInteractor: NSObject {
    var output: ChangePINInteractorOutput?
    
    let walletManager : WalletManager
    let dataManager : WalletDataManager
    let apiManager : ApiManager
    
    init(walletManager: WalletManager, dataManager: WalletDataManager, apiManager: ApiManager) {
        self.walletManager = walletManager
        self.dataManager = dataManager
        self.apiManager = apiManager
    }
}
extension ChangePINInteractor: ChangePINInteractorInput {
    func changePIN(currentPIN: String, newPIN: String) {
        
    }
}
