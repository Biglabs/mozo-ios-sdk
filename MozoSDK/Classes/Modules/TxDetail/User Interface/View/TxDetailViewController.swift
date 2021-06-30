//
//  TxDetailViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/25/18.
//

import Foundation
import UIKit

class TxDetailViewController: MozoBasicViewController {
    var eventHandler : TxDetailModuleInterface?
    var displayItem: TxDetailDisplayItem!
    
    //Outlets
    @IBOutlet weak var actionImg: UIImageView!
    @IBOutlet weak var lbTxType: UILabel!
    @IBOutlet weak var lbDateTime: UILabel!
    @IBOutlet weak var lbActionType: UILabel!
    @IBOutlet weak var addressBookView: AddressBookView!
    @IBOutlet weak var lbAddress: CopyableLabel!
    @IBOutlet weak var secondLineTopConstraint: NSLayoutConstraint! // Default: 57, with address book: 99
    @IBOutlet weak var lbAmountValue: UILabel!
    @IBOutlet weak var lbAmountValueExchange: UILabel!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbAmountValueExchange.isHidden = !Configuration.SHOW_MOZO_EQUIVALENT_CURRENCY
        if navigationController?.viewControllers.count ?? 0 > 2 {
            enableBackBarButton()
        }
        saveBtn.roundCorners(cornerRadius: 0.08, borderColor: ThemeManager.shared.main, borderWidth: 1)
        addressBookView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Transaction Detail".localized
        updateView()
    }
    
    func updateView() {
        var imageName = "ic_received_circle"
        if displayItem.type == .Received || displayItem.action == TransactionType.Received.value {
            lbTxType.text = TransactionType.Received.value.localized
            lbActionType.text = "From".localized
        } else {
            imageName = (
                displayItem.type == .All && displayItem.addressFrom == displayItem.addressTo
            ) ? "ic_transfer_myself" : "ic_sent_circle"
            lbTxType.text = TransactionType.Sent.value.localized
            lbActionType.text = "To".localized
        }
        actionImg.image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        lbDateTime.text = displayItem.dateTime
        
        let address = displayItem.action == TransactionType.Sent.value ? displayItem.addressTo : displayItem.addressFrom
        
        var displayEnum = TransactionDisplayContactEnum.NoDetail
        
        if let addressBook = DisplayUtils.buildContactDisplayItem(address: address) {
            addressBookView.isHidden = false
            lbAddress.isHidden = true
            addressBookView.addressBook = addressBook
            addressBookView.btnClear.isHidden = true
            displayEnum = addressBook.isStoreBook ? .StoreBookDetail : .AddressBookDetail
            secondLineTopConstraint.constant = 99
        } else {
            addressBookView.isHidden = true
            lbAddress.isHidden = false
            lbAddress.text = address
            secondLineTopConstraint.constant = 57
        }
        
        lbAddress.text = address
        let amount = displayItem.amount
        lbAmountValue.text = "\(amount.roundAndAddCommas())"
        lbAmountValueExchange.text = DisplayUtils.getExchangeTextFromAmount(amount)
        
        saveView.isHidden = displayEnum != .NoDetail
    }
    
    @IBAction func touchedBtnSave(_ sender: Any) {
        let address = displayItem.action == TransactionType.Sent.value ? displayItem.addressTo : displayItem.addressFrom
        eventHandler?.requestAddToAddressBook(address)
    }
}
extension TxDetailViewController: AddressBookViewDelegate {
    func didTouchClear() {
    }
    
    func openContactDetails(_ id: Int64, _ isStoreContact: Bool) {
        if isStoreContact {
            eventHandler?.requestCloseAllUI()
            NotificationCenter.default.post(name: .openStoreDetailsFromHistory, object: nil, userInfo: ["id": id])
        }
    }
}
