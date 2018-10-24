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
    @IBOutlet weak var lbBalance: UILabel!
    @IBOutlet weak var lbBalanceExchange: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var lbActionDetailView: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var lbNameDetailView: UILabel!
    @IBOutlet weak var lbAddressDetailView: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbAmountValue: UILabel!
    @IBOutlet weak var lbAmountValueExchange: UILabel!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    
    //Constraints
    @IBOutlet weak var userImgWidthCstr: NSLayoutConstraint!
    @IBOutlet weak var walletAddressTopCstr: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        setBtnBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    func setBtnBorder() {
        saveBtn.roundCorners(cornerRadius: 0.08, borderColor: ThemeManager.shared.main, borderWidth: 1)
    }
    
    func updateView() {
        let imageName = displayItem.action == TransactionType.Sent.value ? "ic_sent_circle" : "ic_received_circle"
        actionImg.image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        lbTxType.text = displayItem.action
        lbDateTime.text = displayItem.dateTime
        
        let address = displayItem.action == TransactionType.Sent.value ? displayItem.addressTo : displayItem.addressFrom
        let list = SafetyDataManager.shared.addressBookList
        if let addressBook = AddressBookDTO.addressBookFromAddress(address, array: list) {
            // TODO: Search from <Store Book>
            detailView.isHidden = false
            lbActionDetailView.text = displayItem.action == TransactionType.Sent.value ? "To" : "From"
            // TODO: Change userImg in case the address coming from <Store Book>, including image width and image
            lbNameDetailView.text = addressBook.name
            // TODO: Set hidden false and set physical address in case the address coming from <Store Book>
            lbAddressDetailView.isHidden = true
        } else {
            detailView.isHidden = true
        }
        
        if detailView.isHidden {
            walletAddressTopCstr.constant = 28
        } else {
            walletAddressTopCstr.constant = 96
            // TODO: Change constant in case the address coming from <Store Book>, constant will be 117
        }
        
        lbAddress.text = address
        let amount = displayItem.amount
        lbAmountValue.text = "\(amount)"
        var exAmount = "0.0"
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            if let type = CurrencyType(rawValue: rateInfo.currency ?? "") {
                let rate = rateInfo.rate ?? 0
                let amountValue = (displayItem.exAmount * rate).rounded(toPlaces: type.decimalRound)
                exAmount = "\(type.unit)\(amountValue)"
            }
        }
        lbAmountValueExchange.text = exAmount
        
        saveView.isHidden = !detailView.isHidden
    }
    
    @IBAction func touchedBtnSave(_ sender: Any) {
        let address = displayItem.action == TransactionType.Sent.value ? displayItem.addressTo : displayItem.addressFrom
        eventHandler?.requestAddToAddressBook(address)
    }
}
