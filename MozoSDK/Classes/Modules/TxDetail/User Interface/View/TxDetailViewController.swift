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
        if navigationController?.viewControllers.count ?? 0 > 2 {
            enableBackBarButton()
        }
        setBtnBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Transaction Detail".localized
        updateView()
    }
    
    func setBtnBorder() {
        saveBtn.roundCorners(cornerRadius: 0.08, borderColor: ThemeManager.shared.main, borderWidth: 1)
    }
    
    func updateView() {
        let imageName = displayItem.action == TransactionType.Sent.value ? "ic_sent_circle" : "ic_received_circle"
        actionImg.image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        lbTxType.text = displayItem.action.localized
        lbDateTime.text = displayItem.dateTime
        
        lbActionType.text = (displayItem.action == TransactionType.Sent.value ? "To" : "From").localized
        
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
