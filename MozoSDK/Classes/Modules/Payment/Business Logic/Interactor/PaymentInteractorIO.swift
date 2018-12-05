//
//  PaymentInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
protocol PaymentInteractorInput {
    func loadTokenInfo()
    func getListPaymentRequest(page: Int)
    func validateValueFromScanner(_ scanValue: String)
}
protocol PaymentInteractorOutput {
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO)
    func didReceiveError(_ error: String?)
    func finishGetListPaymentRequest(_ list: [PaymentRequestDTO], forPage: Int)
    func errorWhileLoadPaymentRequest(_ error: ConnectionError)
    
    func didValidateValueFromScanner()
}
