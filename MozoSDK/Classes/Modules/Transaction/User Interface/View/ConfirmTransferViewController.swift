//
//  ConfirmTransferViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/25/18.
//

import Foundation
import UIKit

class ConfirmTransferViewController: MozoBasicViewController {
    var eventHandler : TransactionModuleInterface?
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbAmountValue: UILabel!
    @IBOutlet weak var lbAmountValueExchange: UILabel!
    @IBOutlet weak var addressBookView: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbNameAddress: UILabel!
    @IBOutlet weak var ctrAmount: NSLayoutConstraint!
    
    var transaction : TransactionDTO?
    var tokenInfo: TokenInfoDTO?
    var displayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCircleView()
        enableBackBarButton()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fix issue: Title is not correct after showing alert
        self.title = "Confirmation"
    }
    
    func setupCircleView() {
        circleView.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
    }
    
    func updateView() {
        lbAddress.text = transaction?.outputs?.first?.addresses![0]
        let amount = transaction?.outputs?.first?.value?.convertOutputValue(decimal: tokenInfo?.decimals ?? 0) ?? 0.0
        lbAmountValue.text = "(\(amount))"
        
        if let displayName = displayName {
            lbAddress.isHidden = true
            addressBookView.isHidden = false
            lbName.text = displayName
            lbNameAddress.text = lbAddress.text
            ctrAmount.constant += 18
        }
        
        var exAmount = "0.0"
        
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            if let type = CurrencyType(rawValue: rateInfo.currency ?? "") {
                let rate = rateInfo.rate ?? 0
                let amountValue = (amount * rate).rounded(toPlaces: type.decimalRound)
                exAmount = "\(type.unit)\(amountValue)"
            }
        }
        
        lbAmountValueExchange.text = exAmount
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        eventHandler?.sendConfirmTransaction(transaction!)
    }
}
extension ConfirmTransferViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        
    }
    
    func didTouchTryAgainButton() {
        print("User try transfer transaction again.")
        removeMozoPopupError()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.eventHandler?.requestToRetryTransfer()
        }
    }
}
extension ConfirmTransferViewController : ConfirmTransferViewInterface {
    func displayTryAgain(_ error: ConnectionError) {
        displayMozoPopupError(error)
        mozoPopupErrorView?.delegate = self
    }
    
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
}
