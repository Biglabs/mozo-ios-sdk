//
//  AccessDeniedViewController.swift
//  MozoRetailer
//
//  Created by Hoang Nguyen on 3/13/19.
//  Copyright © 2019 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
class AccessDeniedViewController: UIViewController {
    @IBOutlet weak var imgUserTopConstraint: NSLayoutConstraint! // Default 50
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgFailed: UIImageView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnLogoutBottomConstraint: NSLayoutConstraint! // Default 38
    
    @IBOutlet weak var lbExplain: UILabel!
    @IBOutlet weak var imgTelegram: UIImageView!
    @IBOutlet weak var imgZalo: UIImageView!
    @IBOutlet weak var imgKakaoTalk: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setImages()
        setupTarget()
    }
    
    func errorTextAfterRemovingTexts(errorText: String) -> String {
        let removeTexts = [" (email + phone)", " (phone + email)", " (이메일 + 전화)", " (전화 + 이메일)"]
        var finalText = errorText.localized
        for item in removeTexts {
            finalText = finalText.replace(item, withString: "")
        }
        return finalText
    }
    
    func setupLayout() {
        let bundle = BundleManager.mozoBundle()
        let imageUser = UIImage(named: "ic_notif_user_come", in: bundle, compatibleWith: nil)
        imgUser.image = imageUser
        let imageFailed = UIImage(named: "ic_failed", in: bundle, compatibleWith: nil)
        imgFailed.image = imageFailed
        btnLogout.roundCorners(cornerRadius: 0.015, borderColor: .white, borderWidth: 0.1)
        
        let text = "Your account has been deactivated temporarily. Please sign in with other account or contact us for more information (phone + email)".localized
        lbExplain.text = errorTextAfterRemovingTexts(errorText: text)
        
        // Update layout for iPhone 5 below
        if UIScreen.main.nativeBounds.height <= 1136 {
            imgUserTopConstraint.constant = 10
            btnLogoutBottomConstraint.constant = 8
        }
    }
    
    @IBAction func touchbtnLogout(_ sender: Any) {
        MozoSDK.logout()
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
            urlString = "https://t.me/MozoXRetailerApp"
        } else if tappedImage == imgZalo {
            urlString = "https://zalo.me/4501855982660092369"
        }
        openLink(link: urlString)
    }
}
extension AccessDeniedViewController {
    public static func viewControllerFromXIB() -> AccessDeniedViewController {
        let bundle = BundleManager.mozoBundle()
        let viewController = AccessDeniedViewController(nibName: String(describing: AccessDeniedViewController.self), bundle: bundle)
        return viewController
    }
}
