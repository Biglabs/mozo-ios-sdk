//
//  PaymentTableViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/5/18.
//

import Foundation
let PAYMENT_TABLE_VIEW_CELL_IDENTIFIER = "PaymentTableViewCell"

public class PaymentTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var lbDateTime: UILabel?
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbNameAddress: UILabel!
    var paymentItem : PaymentRequestDisplayItem? {
        didSet {
            bindData()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupBorder()
    }
    
    func setupBorder() {
        containerView?.roundCorners(cornerRadius: 0.02, borderColor: ThemeManager.shared.border, borderWidth: 1)
    }
    
    func bindData(){
        lbDateTime?.text = paymentItem?.date
        let amount = paymentItem?.amount ?? 0
        let amountText = "\(amount.roundAndAddCommas()) MozoX"
        lbAmount.text = amountText
        lbNameAddress.text = paymentItem?.displayNameAddress
    }
}
