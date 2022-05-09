//
//  MozoErrorVC.swift
//  MozoSDK
//
//  Created by MAC on 21/04/2022.
//

import Foundation
import UIKit

public protocol MozoErrorDelegate {
    func didCloseMozoPopupContact()
}
class MozoErrorVC: UIViewController {
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var imgTelegram: UIImageView!
    @IBOutlet weak var imgZalo: UIImageView!
    @IBOutlet weak var imgKakao: UIImageView!
    
    private var errorMessage: String? = nil
    private var delegate: MozoErrorDelegate? = nil
    
    override func viewDidLoad() {
        if let msg = errorMessage {
            lbMessage.text = msg
        }
        
        let bundle = BundleManager.mozoBundle()
        imgTelegram.image = UIImage(named: "ic_telegram", in: bundle, compatibleWith: nil)
        imgZalo.image = UIImage(named: "ic_zalo", in: bundle, compatibleWith: nil)
        imgKakao.image = UIImage(named: "ic_kakao", in: bundle, compatibleWith: nil)
        
        let touchedOutSide = UITapGestureRecognizer(target: self, action: #selector(touchedOutSide))
        self.view.addGestureRecognizer(touchedOutSide)
        self.lbMessage.superview?.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(touchedWhiteContainer))
        )
        self.imgTelegram.superview?.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(touchedTelegram))
        )
        self.imgZalo.superview?.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(touchedZalo))
        )
        self.imgKakao.superview?.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(touchedKakao))
        )
    }
    
    @objc func touchedOutSide() {
        dismiss(animated: true)
    }
    
    @objc func touchedWhiteContainer() {
        // MARK: prevent dismiss on tap
    }
    
    @objc func touchedTelegram() {
        let urlString = MozoSDK.appType == .Shopper ? "https://t.me/MozoX_App" : "https://t.me/MozoX_Retailer"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func touchedZalo() {
        guard let url = URL(string: "https://zalo.me/4501855982660092369") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func touchedKakao() {
        guard let url = URL(string: "https://open.kakao.com/o/g6tvra5") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func touchedOk(_ sender: Any) {
        delegate?.didCloseMozoPopupContact()
        delegate = nil
        dismiss(animated: true)
    }
    
    class func newVC() -> MozoErrorVC {
        let storyboard = UIStoryboard(name: "Mozo", bundle: BundleManager.mozoBundle())
        let controller = storyboard.instantiateViewController(withIdentifier: "MozoErrorVC")
        return controller as! MozoErrorVC
    }
    
    class func launch(_ error: String? = nil, _ delegate: MozoErrorDelegate? = nil) {
        if let topVC = DisplayUtils.getTopViewController() {
            if topVC is MozoErrorVC {
                return
            }
            let vc = MozoErrorVC.newVC()
            vc.errorMessage = error
            vc.delegate = delegate
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            topVC.present(vc, animated: true)
        }
    }
}
