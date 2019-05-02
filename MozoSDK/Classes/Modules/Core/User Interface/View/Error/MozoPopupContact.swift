//
//  MozoPopupContact.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/1/19.
//

import Foundation

class MozoPopupContact: MozoView {
    @IBOutlet weak var imgTelegram: UIImageView!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var imgZalo: UIImageView!
    @IBOutlet weak var imgKakaoTalk: UIImageView!
    @IBOutlet weak var btnOK: UIButton!
    
    var modalCloseHandler: (() -> Void)?
    
    let removeTexts = [" (email + phone)", " (phone + email)", " (이메일 + 전화)", " (전화 + 이메일)"]
    
    var errorMessage = "Can not connect to MozoX servers. Contact your agency for more infomation.".localized {
        didSet {
            if lbError != nil {
                var finalText = errorMessage
                for item in removeTexts {
                    finalText = finalText.replace(item, withString: "")
                }
                lbError.text = finalText
            }
        }
    }
    
    override func identifier() -> String {
        return "MozoPopupContact"
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        setImages()
        setupTarget()
        setupButton()
    }
    
    func setupButton() {
        btnOK.roundCorners(cornerRadius: 0.15, borderColor: .white, borderWidth: 0.1)
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
            urlString = "https://t.me/MozoXApp"
        } else if tappedImage == imgZalo {
            urlString = "https://zalo.me/428563224447178063"
        }
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    public func dismissView() {
        modalCloseHandler?()
    }
    
    @IBAction func touchedOkBtn(_ sender: Any) {
        dismissView()
    }
}
