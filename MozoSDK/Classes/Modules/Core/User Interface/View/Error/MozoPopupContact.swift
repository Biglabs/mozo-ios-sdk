//
//  MozoPopupContact.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/1/19.
//

import Foundation
@objc public protocol MozoPopupContactDelegate {
    func didCloseMozoPopupContact()
}
class MozoPopupContact: MozoView {
    @IBOutlet weak var imgTelegram: UIImageView!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var imgZalo: UIImageView!
    @IBOutlet weak var imgKakaoTalk: UIImageView!
    @IBOutlet weak var btnOK: UIButton!
    
    var modalCloseHandler: (() -> Void)?
    
    var appType = AppType.Shopper
    
    let removeTexts = [" (email + phone)", " (phone + email)", " (이메일 + 전화)", " (전화 + 이메일)"]
    
    var errorMessage = "error_fatal".localized {
        didSet {
            if lbError != nil {
                var finalText = errorMessage.localized
                for item in removeTexts {
                    finalText = finalText.replace(item, withString: "")
                }
                lbError.text = finalText
            }
        }
    }
    
    var delegate: MozoPopupContactDelegate?
    
    override func identifier() -> String {
        return "MozoPopupContact"
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        setImages()
        setupTarget()
        btnOK.roundedCircle()
    }
    
    func setImages() {
        let bundle = BundleManager.mozoBundle()
        let telegram = UIImage(named: "ic_telegram", in: bundle, compatibleWith: nil)
        imgTelegram.image = telegram
        let zalo = UIImage(named: "ic_zalo", in: bundle, compatibleWith: nil)
        imgZalo.image = zalo
        let kakao = UIImage(named: "ic_kakao", in: bundle, compatibleWith: nil)
        imgKakaoTalk.image = kakao
    }
    
    func setupTarget() {
        let tapTelegramGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        imgTelegram.isUserInteractionEnabled = true
        imgTelegram.addGestureRecognizer(tapTelegramGR)
        
        let tapZaloGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        imgZalo.isUserInteractionEnabled = true
        imgZalo.addGestureRecognizer(tapZaloGR)
        
        let tapKakaoGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        imgKakaoTalk.isUserInteractionEnabled = true
        imgKakaoTalk.addGestureRecognizer(tapKakaoGR)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        var urlString = "https://open.kakao.com/o/g6tvra5"
        if tappedImage == imgTelegram {
            urlString = appType == .Shopper ? "https://t.me/MozoX_App" : "https://t.me/MozoX_Retailer"
        } else if tappedImage == imgZalo {
            urlString = "https://zalo.me/4501855982660092369"
        }
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    public func dismissView() {
        modalCloseHandler?()
        delegate?.didCloseMozoPopupContact()
    }
    
    @IBAction func touchedOkBtn(_ sender: Any) {
        dismissView()
    }
}
