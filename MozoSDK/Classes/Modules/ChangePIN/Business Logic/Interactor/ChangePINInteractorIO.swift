//
//  ChangePINInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
protocol ChangePINInteractorInput {
    func changePIN(currentPIN: String, newPIN: String)
}
protocol ChangePINInteractorOutput {
    func changePINFailedWithError(_ error: ConnectionError)
    func changePINSuccess()
}
