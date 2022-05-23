//
//  HeaderMozoUserWalletTableViewCell.swift
//  MozoSDK
//
//  Created by Min's Macbook on 20/04/2022.
//

import UIKit

protocol HeaderMozoUserWalletTableViewCellDelegate: NSObject {
    func didRequest()
    func didBuy()
    func didInfo()
    func didSend()
    func didAllHistory()
}

class HeaderMozoUserWalletTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vBGWallet: UIView!

    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblMozoTotal: UILabel!
    @IBOutlet weak var lblMozoToday: UILabel!
    
    @IBOutlet weak var lblRequest: UILabel!
    @IBOutlet weak var lblBuy: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblSend: UILabel!
    
    weak var delegate: HeaderMozoUserWalletTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.customCell()
    }
    
    func customCell() {
        self.vBGWallet.setCornerRadius(24.0)
        
        self.lblTotal.text = "Tổng số dư"
        self.lblTotal.font = UIFont.systemFont(ofSize: 16.0)
        
        self.lblRequest.text = "Request".localized
        self.lblBuy.text = "Redeem".localized
        self.lblInfo.text = "info_wallet".localized
        self.lblSend.text = "Send".localized
    }

    func customAttributedTextMozoTotal(mozo: Double) {
        let attriString = NSAttributedString(string: "\(mozo.addCommas())", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 32.0), NSMutableAttributedString.Key.foregroundColor : UIColor.init(hexString: "FFFFFF")])
        let attriString1 = NSAttributedString(string: " Mozo", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0), NSMutableAttributedString.Key.foregroundColor : UIColor.init(hexString: "CDE2FF")])
        
        let strContent = NSMutableAttributedString(attributedString: attriString)
        strContent.append(NSMutableAttributedString(attributedString: attriString1))
        
        self.lblMozoTotal.attributedText = strContent
    }
    
    func customAttributedTextMozoToday(mozo: Double) {
        
        let attriString = NSAttributedString(string: self.loadMozoToday(mozo: mozo), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0), NSMutableAttributedString.Key.foregroundColor : UIColor.init(hexString: "FFFFFF")])
        let attriString1 = NSAttributedString(string: " Mozo trong ngày", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0), NSMutableAttributedString.Key.foregroundColor : UIColor.init(hexString: "CDE2FF")])

        let strContent = NSMutableAttributedString(attributedString: attriString)
        strContent.append(NSMutableAttributedString(attributedString: attriString1))
        
        self.lblMozoToday.attributedText = strContent
    }
    
    func loadMozoToday(mozo: Double) -> String {
        if mozo > 0 {
            return " +\(mozo.addCommas())"
        }
        
        return " 0"
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Action
    @IBAction func didRequest(_ sender: Any) {
        self.delegate?.didRequest()
    }
    
    @IBAction func didBuyMozo(_ sender: Any) {
        self.delegate?.didBuy()
    }
    
    @IBAction func didInfoWallet(_ sender: Any) {
        self.delegate?.didInfo()
    }
    
    @IBAction func didSendMozo(_ sender: Any) {
        self.delegate?.didSend()
    }
    
    @IBAction func didAllHistory(_ sender: Any) {
        self.delegate?.didAllHistory()
    }

}
