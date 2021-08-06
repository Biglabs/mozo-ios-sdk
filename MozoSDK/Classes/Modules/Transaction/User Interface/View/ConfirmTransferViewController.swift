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
    @IBOutlet weak var lbAddress: CopyableLabel!
    @IBOutlet weak var lbAmountValue: UILabel!
    @IBOutlet weak var lbAmountValueExchange: UILabel!
    @IBOutlet weak var lbReceiver: UILabel!
    @IBOutlet weak var addressBookView: AddressBookView!
    
    @IBOutlet weak var storeBookView: UIView!
    @IBOutlet weak var lbStoreName: UILabel!
    @IBOutlet weak var lbStorePhysicalAddress: CopyableLabel!
    @IBOutlet weak var lbStoreOffchainAddress: CopyableLabel!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var layoutConstraint: NSLayoutConstraint!
    
    var transaction : TransactionDTO?
    var tokenInfo: TokenInfoDTO?
    var displayContactItem: AddressBookDisplayItem?
    var moduleRequest: Module = .Transaction
    
    let defaultHeight : CGFloat = 53
    let addressBookHeight: CGFloat = 108
    let storeBookHeight: CGFloat = 134
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbAmountValueExchange.isHidden = !Configuration.SHOW_MOZO_EQUIVALENT_CURRENCY
        setupCircleView()
        enableBackBarButton()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fix issue: Title is not correct after showing alert
        var text = "title_send_mozo"
        switch moduleRequest {
        case .Payment:
            text = "title_request_mozo"
        case .TopUp:
            text = "Deposit"
        default:
            break
        }
        self.title = text.localized
    }
    
    func setupCircleView() {
        circleView.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
    }
    
    func updateView() {
        let address = transaction?.outputs?.first?.addresses![0] ?? ""
        lbAddress.text = address
        let amount = transaction?.outputs?.first?.value?.convertOutputValue(decimal: tokenInfo?.decimals ?? 0) ?? 0.0
        lbAmountValue.text = amount.roundAndAddCommas()
        
        let labelText = "Receiver Address"
        var displayType = TransactionDisplayContactEnum.NoDetail
        if moduleRequest == .TopUp {
            lbAddress.isHidden = true
            
            displayContactItem = AddressBookDisplayItem.TopUpAddressBookDisplayItem
            addressBookView.isHidden = false
            addressBookView.btnClear.isHidden = true
            addressBookView.addressBook = displayContactItem
            displayType = .AddressBookDetail
        } else {
            if let displayContactItem = displayContactItem {
                lbAddress.isHidden = true
                if displayContactItem.isStoreBook {
    //                labelText = "Receiver"
                    storeBookView.isHidden = false
                    lbStoreName.text = displayContactItem.name
                    lbStorePhysicalAddress.text = displayContactItem.physicalAddress
                    lbStoreOffchainAddress.text = displayContactItem.address
                    displayType = .StoreBookDetail
                } else {
    //                labelText = "To"
                    addressBookView.isHidden = false
                    addressBookView.btnClear.isHidden = true
                    addressBookView.addressBook = displayContactItem
                    displayType = .AddressBookDetail
                }
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
        
        lbAmountValueExchange.text = DisplayUtils.getExchangeTextFromAmount(amount)
    }
    
    @IBAction func btnConfirmTapped(_ sender: Any) {
        if moduleRequest == .TopUp {
            eventHandler?.topUpConfirmTransaction(transaction!, tokenInfo: tokenInfo!)
            return
        }
        eventHandler?.sendConfirmTransaction(transaction!, tokenInfo: self.tokenInfo!)
    }
}
extension ConfirmTransferViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        removeSpinner()
    }
    
    func didTouchTryAgainButton() {
        print("ConfirmTransferViewController - User try transfer transaction again.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.eventHandler?.requestToRetryTransfer()
        }
    }
}
extension ConfirmTransferViewController : ConfirmTransferViewInterface {
    func displayTryAgain(_ error: ConnectionError) {
        DisplayUtils.displayTryAgainPopup(error: error, delegate: self)
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
