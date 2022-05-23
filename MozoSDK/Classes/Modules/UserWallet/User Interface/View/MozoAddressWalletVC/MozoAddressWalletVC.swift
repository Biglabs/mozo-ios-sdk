//
//  MozoAddressWalletVC.swift
//  MozoSDK
//
//  Created by Min's Macbook on 19/04/2022.
//

import UIKit
import MBProgressHUD
class MozoAddressWalletVC: UIViewController {

    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var qrCodeView: UIView!
    @IBOutlet weak var addressWalletView: UIView!
    
    @IBOutlet weak var lblInfoWallet: UILabel!
    @IBOutlet weak var lblQRMozo: UILabel!
    @IBOutlet weak var lblAddressWallet: UILabel!
    
    @IBOutlet weak var imgQRCode: UIImageView!
    
    @IBOutlet weak var btAddressWallet: UIButton!
    
    var displayItem : DetailInfoDisplayItem?

    var hud: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customView()
        self.loadData(self.displayItem!)
    }

    func customView() {
        self.addressView.setCornerRadius(20.0, corners: [.topLeft, .topRight])
        
        self.qrCodeView.alpha = 0.1
        self.qrCodeView.setCornerRadius(16.0)
        
        self.addressWalletView.setCornerRadius(self.addressWalletView.frame.height/2)
        
        self.lblInfoWallet.text = "info_wallet".localized
        self.lblQRMozo.text = "Scan QR Mozo".localized
        self.lblAddressWallet.text = "Wallet Address".localized
        
        self.btAddressWallet.titleLabel?.numberOfLines = 1
    }
    
    func loadData(_ displayItem: DetailInfoDisplayItem) {
        if !displayItem.address.isEmpty {
            let qrImg = DisplayUtils.generateQRCode(from: displayItem.address)
            imgQRCode.image = qrImg
            
            btAddressWallet.setTitle(displayItem.address, for: .normal)
        }
    }
    
    func copyAddressAndShowHud() {
        UIPasteboard.general.string = btAddressWallet.titleLabel?.text ?? ""
        showHud()
    }
    
    func showHud() {
        hud = MBProgressHUD.showAdded(to: self.addressView, animated: true)
        hud?.mode = .text
        hud?.label.text = "Copied to clipboard".localized
        hud?.label.textColor = .white
        hud?.label.numberOfLines = 2
        hud?.offset = CGPoint(x: 0, y: -300)
        hud?.bezelView.color = UIColor(hexString: "333333")
        hud?.isUserInteractionEnabled = false
        hud?.hide(animated: true, afterDelay: 1.5)
    }

    //MARK: - Action
    @IBAction func didCopyAddressWallet(_ sender: Any) {
        self.copyAddressAndShowHud()
    }
    
    @IBAction func didClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
