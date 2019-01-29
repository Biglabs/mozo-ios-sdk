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
    @IBOutlet weak var lbReceiver: UILabel!
    @IBOutlet weak var addressBookView: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbNameAddress: UILabel!
    
    @IBOutlet weak var storeBookView: UIView!
    @IBOutlet weak var lbStoreName: UILabel!
    @IBOutlet weak var lbStorePhysicalAddress: UILabel!
    @IBOutlet weak var lbStoreOffchainAddress: UILabel!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var layoutConstraint: NSLayoutConstraint!
    
    var transaction : TransactionDTO?
    var tokenInfo: TokenInfoDTO?
    var displayContactItem: AddressBookDisplayItem?
    var isPaymentRequest: Bool = false
    
    let defaultHeight : CGFloat = 53
    let addressBookHeight: CGFloat = 108
    let storeBookHeight: CGFloat = 134
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCircleView()
        enableBackBarButton()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fix issue: Title is not correct after showing alert
        self.title = (isPaymentRequest ? "Request MozoX" : "Send MozoX").localized
    }
    
    func setupCircleView() {
        circleView.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
    }
    
    func updateView() {
        let address = transaction?.outputs?.first?.addresses![0] ?? ""
        lbAddress.text = address
        let amount = transaction?.outputs?.first?.value?.convertOutputValue(decimal: tokenInfo?.decimals ?? 0) ?? 0.0
        lbAmountValue.text = amount.roundAndAddCommas()
        
        var labelText = "Receiver Address"
        var displayType = TransactionDisplayContactEnum.NoDetail
        if let displayContactItem = displayContactItem {
            lbAddress.isHidden = true
            if displayContactItem.isStoreBook {
                labelText = "Receiver"
                storeBookView.isHidden = false
                lbStoreName.text = displayContactItem.name
                lbStorePhysicalAddress.text = displayContactItem.physicalAddress
                lbStoreOffchainAddress.text = displayContactItem.address
                displayType = .StoreBookDetail
            } else {
                labelText = "To"
                addressBookView.isHidden = false
                lbName.text = displayContactItem.name
                lbNameAddress.text = lbAddress.text
                displayType = .AddressBookDetail
            }
        }
        lbReceiver.text = labelText.localized
        
        switch displayType {
        case .AddressBookDetail:
            layoutConstraint.constant = addressBookHeight
        case .StoreBookDetail:
            layoutConstraint.constant = storeBookHeight
        default:
            layoutConstraint.constant = defaultHeight
        }
        
        var exAmount = "0.0"
        
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            if let type = CurrencyType(rawValue: rateInfo.currency ?? ""), let curSymbol = rateInfo.currencySymbol {
                let rate = rateInfo.rate ?? 0
                let amountValue = (amount * rate).rounded(toPlaces: type.decimalRound)
                exAmount = "\(curSymbol)\(amountValue.roundAndAddCommas())"
            }
        }
        
        lbAmountValueExchange.text = exAmount
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        eventHandler?.sendConfirmTransaction(transaction!, tokenInfo: self.tokenInfo!)
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
