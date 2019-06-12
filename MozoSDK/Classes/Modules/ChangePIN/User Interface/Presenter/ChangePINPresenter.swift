//
//  ChangePINPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINPresenter: NSObject {
    var wireframe: ChangePINWireframe?
    var processInterface: ChangePINProcessViewInterface?
    var interactor: ChangePINInteractorInput?
    
    var currentPinToChange: String?
    
    func processChangePIN() {
        
    }
}
extension ChangePINPresenter: ChangePINModuleInterface {
    func finishChangePIN() {
        wireframe?.dismissModuleInterface()
    }
}
extension ChangePINPresenter: ChangePINInteractorOutput {
    func changePINFailedWithError(_ error: ConnectionError) {
        
    }
    
    func changePINSuccess() {
        wireframe?.presentChangePINSuccessInterface()
    }
}
extension ChangePINPresenter: ChangePINModuleDelegate {
    func verifiedCurrentPINSuccess(_ pin: String) {
        self.currentPinToChange = pin
    }
    
    func inputNewPINSuccess(_ pin: String) {
        
    }
}
