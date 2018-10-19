//
//  TxHistoryTableViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/3/18.
//

import Foundation
import UIKit

public class TxHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbAction: UILabel!
    @IBOutlet weak var lbDateTime: UILabel?
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbExchangeValue: UILabel?
    @IBOutlet weak var statusView: UIView!
    var txHistory : TxHistoryDisplayItem? {
        didSet {
            bindData()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindData(){
        lbAction.text = txHistory?.action
        lbDateTime?.attributedText = txHistory?.fromNameWithDate
        var imageName = "ic_received_circle"
        if txHistory?.action == TransactionType.Received.value {
            lbAmount.textColor = ThemeManager.shared.main
            lbAmount.text = "+\(txHistory?.amount ?? 0)"
        } else {
            lbAmount.textColor = ThemeManager.shared.title
            lbAmount.text = "-\(txHistory?.amount ?? 0)"
            imageName = "ic_sent_circle"
        }
        img.image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        lbExchangeValue?.text = ""
//        lbExchangeValue?.text = "₩\(txHistory?.exAmount ?? 0)"
        
    }
}
