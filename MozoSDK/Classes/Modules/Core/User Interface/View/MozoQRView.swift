//
//  MozoQRView.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation
class MozoQRView : MozoView {
    @IBOutlet weak var imgQR: UIImageView!
    weak var coverView: UIView!
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    var qrImage : UIImage? {
        didSet {
            loadImageData()
        }
    }
    
    override func identifier() -> String {
        return "MozoQRView"
    }
    
    func loadImageData() {
        if let img = qrImage {
            imgQR.image = img
        }
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        setBorders()
    }
    
    func setBorders() {
//        imgContainerView.roundCorners(borderColor: ThemeManager.shared.disable, borderWidth: 1.2)
        btnClose.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
        btnClose.transform = btnClose.transform.rotated(by: CGFloat.pi / 4)
    }
    
    @IBAction func touchedCloseBtn(_ sender: Any) {
        coverView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
