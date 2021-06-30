//
//  TxHistoryTableViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/3/18.
//

import Foundation
import UIKit

public class TxHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var topUpContainerView: UIView!
    @IBOutlet weak var topUpImageView: UIImageView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbAction: UILabel!
    @IBOutlet weak var lbFromTo: UILabel!
    @IBOutlet weak var lbFromToWidthConstraint: NSLayoutConstraint! // Default 27
    @IBOutlet weak var lbNameOrAddress: UILabel!
    @IBOutlet weak var lbNameOrAddressLeadingConstraint: NSLayoutConstraint! // Default 2
    @IBOutlet weak var lbDateTime: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbExchangeValue: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    public var txHistory : TxHistoryDisplayItem? {
        didSet {
            bindData()
        }
    }
    public var type: TransactionType = .All
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindData(){
        lbAction.text = txHistory?.action.localized
//        lbDateTime?.attributedText = txHistory?.fromNameWithDate
        let fromtoText = txHistory?.fromtoText ?? ""
        
        let descriptor = UIFont.boldSystemFont(ofSize: 11).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
        let font : UIFont = UIFont.init(descriptor: descriptor!, size: 11)
        lbNameOrAddress.font = font
        let fromToWithNameOrAddress = (fromtoText.isEmpty ? txHistory?.nameOrAddress : "\(fromtoText) \(txHistory?.nameOrAddress ?? "")") ?? ""
        let finalStr = NSAttributedString(string: fromToWithNameOrAddress)
        let lStrLabelText = NSMutableAttributedString(attributedString: finalStr)
        let string = NSString(string: fromToWithNameOrAddress)
        let range = string.range(of: txHistory?.nameOrAddress ?? "")
        lStrLabelText.addAttribute(.font, value: font, range: range)
        lStrLabelText.addAttribute(.foregroundColor, value: ThemeManager.shared.textSection, range: range)
        lbNameOrAddress.attributedText = lStrLabelText
        lbNameOrAddress.lineBreakMode = (txHistory?.name.isEmpty ?? false) ? .byTruncatingTail : .byTruncatingMiddle
        
        let dateStr = txHistory?.date ?? ""
        lbDateTime.text = dateStr
        
        let amount = txHistory?.amount ?? 0
        let amountText = amount.roundAndAddCommas()
        // With top up transaction, image tint color will be changed to ThemeManager.shared.success
        if let topUpReason = txHistory?.topUpReason {
            if topUpReason == .TOP_UP_ADD_MORE {
                img.isHidden = true
                topUpContainerView.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
                topUpContainerView.isHidden = false
                topUpImageView.image = UIImage(named: "ic_receive", in: BundleManager.mozoBundle(), compatibleWith: nil)
                topUpContainerView.backgroundColor = ThemeManager.shared.success
                
                lbAmount.textColor = ThemeManager.shared.main
                lbAmount.text = "+\(amountText)"
            } else {
                img.isHidden = false
                topUpContainerView.isHidden = true
                let imageName = "ic_sent_circle"
                img.image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
                
                lbAmount.textColor = ThemeManager.shared.title
                lbAmount.text = "-\(amountText)"
            }
        } else {
            var imageName = "ic_received_circle"
            if type == .Received || txHistory?.action == TransactionType.Received.value {
                lbAmount.textColor = ThemeManager.shared.main
                lbAmount.text = "+\(amountText)"
                lbAction.text = TransactionType.Received.value.localized
            } else {
                lbAmount.textColor = ThemeManager.shared.title
                lbAmount.text = "-\(amountText)"
                imageName = (type == .All && txHistory?.addressFrom == txHistory?.addressTo) ? "ic_transfer_myself" : "ic_sent_circle"
                lbAction.text = TransactionType.Sent.value.localized
            }
            img.image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        }
        lbExchangeValue?.text = ""
//        lbExchangeValue?.text = "₩\(txHistory?.exAmount ?? 0)"
    }
}
