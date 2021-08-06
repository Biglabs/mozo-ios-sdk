//
//  PaymentSendSuccessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/7/18.
//

import Foundation
import UIKit
class PaymentSendSuccessViewController: MozoBasicViewController {
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbAmountEx: UILabel!
    @IBOutlet weak var lbAddressOrName: CopyableLabel!
    @IBOutlet weak var addressBookView: AddressBookView!
    
    var displayItem: PaymentRequestDisplayItem?
    var toAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbAmountEx.isHidden = !Configuration.SHOW_MOZO_EQUIVALENT_CURRENCY
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "title_request_mozo".localized
    }
    
    func bindData() {
        if let displayItem = self.displayItem {
            lbAmount.text = displayItem.amount.roundAndAddCommas()
            
            lbAmountEx.text = DisplayUtils.getExchangeTextFromAmount(displayItem.amount.doubleValue)
            
            if let toAddress = toAddress, let addressBook = DisplayUtils.buildContactDisplayItem(address: toAddress) {
                addressBookView.isHidden = false
                lbAddressOrName.isHidden = true
                addressBookView.addressBook = addressBook
                addressBookView.btnClear.isHidden = true
            } else {
                addressBookView.isHidden = true
                lbAddressOrName.isHidden = false
                lbAddressOrName.text = toAddress
            }
        }
    }
}
