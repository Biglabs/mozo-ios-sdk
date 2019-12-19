//
//  MozoBasicViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/30/18.
//

import Foundation
import UIKit

public class MozoBasicViewController : UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    func enableBackBarButton() {
        self.navigationController?.navigationBar.backItem?.title = "Back".localized
        navigationItem.hidesBackButton = false
    }
    
    func setLeftNavigationBarButton() {
        //your custom view for back image with custom size
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: 40))
        let imageView = UIImageView(frame: CGRect(x: -10, y: 10, width: 20, height: 20))

        if let imgBackArrow = UIImage(named: "ic_left_arrow", in: BundleManager.mozoBundle(), compatibleWith: nil) {
            imageView.image = imgBackArrow.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = ThemeManager.shared.main
        }
        view.addSubview(imageView)

        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 60, height: 18))
        label.text = "Back".localized
        label.textColor = ThemeManager.shared.main

        view.addSubview(label)

        let backTap = UITapGestureRecognizer(target: self, action: #selector(tapBackBtn))
        view.addGestureRecognizer(backTap)

        let leftBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    @objc func tapBackBtn() {
        navigationController?.popViewController(animated: false)
    }
    
    func displayMozoError(_ error: String) {
        if error.isMozoErrorWithContact {
            DisplayUtils.displayMozoErrorWithContact(error)
            return
        }
        let alert = UIAlertController(title: "Error".localized, message: error.localized, preferredStyle: .alert)
        alert.addAction(.init(title: "OK".localized, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayMozoAlertSuccess(completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Success".localized, message: "", preferredStyle: .alert)
        alert.addAction(.init(title: "OK".localized, style: .default, handler: { (action) in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayMozoAlertConfirm(confirmCompletion: (() -> Void)?, notConfirmCompletion: (() -> Void)?) {
        let alert = UIAlertController(title: "Confirm".localized, message: "Are you sure?".localized, preferredStyle: .alert)
        alert.addAction(.init(title: "Yes".localized, style: .default, handler: { (action) in
            confirmCompletion?()
        }))
        alert.addAction(.init(title: "No".localized, style: .default, handler: { (action) in
            notConfirmCompletion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayMozoAlertInfo(infoMessage: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Info".localized, message: infoMessage, preferredStyle: .alert)
        alert.addAction(.init(title: "OK".localized, style: .default, handler: { (action) in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Table - No Content
    var noContentView: UIView?

    func prepareNoContentView(_ frame: CGRect, message: String, imageName: String = "img_no_content") {
        if noContentView != nil {
            return
        }
        noContentView = UIView(frame: frame)
        let image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 156, height: 150))
        imageView.image = image
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 40, height: 18))
        label.textAlignment = .center
        label.text = message.localized
        label.textColor = ThemeManager.shared.disable
        label.font = UIFont.italicSystemFont(ofSize: 15)
        
        imageView.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let lbFrameCenter = CGPoint(x: imageView.center.x, y: imageView.center.y + (imageView.frame.size.height / 2) + 15)
        label.center = lbFrameCenter
        
        noContentView?.addSubview(label)
        noContentView?.addSubview(imageView)
    }
    
    // MARK: Spinner
    var mozoSpinnerView : UIView?
    
    func displayMozoSpinner() {
        navigationItem.hidesBackButton = true
        mozoSpinnerView = UIView.init(frame: self.view.bounds)
        mozoSpinnerView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.color = ThemeManager.shared.main
        ai.startAnimating()
        ai.center = (mozoSpinnerView?.center)!
        
        DispatchQueue.main.async {
            self.mozoSpinnerView?.addSubview(ai)
            self.view.addSubview(self.mozoSpinnerView!)
        }
    }
    
    func removeMozoSpinner(hidesBackButton: Bool = false) {
        DispatchQueue.main.async {
            self.navigationItem.hidesBackButton = hidesBackButton
            self.mozoSpinnerView?.removeFromSuperview()
        }
    }
    
    //MARK: Popup Error
    var mozoPopupErrorView : MozoPopupErrorView?
    
    func displayMozoPopupError(_ error: ConnectionError? = nil) {
//        print("Display popup error with error: \(error)")
        var errorText = error?.apiError?.description
        if error == nil {
            errorText = ConnectionError.apiError_INTERNAL_ERROR.apiError?.description
        }
        if let errorText = errorText, errorText.isMozoErrorWithContact {
            DisplayUtils.displayMozoErrorWithContact(errorText)
            return
        }
        mozoPopupErrorView = MozoPopupErrorView(frame: CGRect(x: 0, y: 0, width: 315, height: 384))
        if let err = error {
            mozoPopupErrorView?.error = err
        }
        
        mozoPopupErrorView?.clipsToBounds = false
        mozoPopupErrorView?.dropShadow()
        mozoPopupErrorView?.containerView.roundCorners(borderColor: .white, borderWidth: 1)
        
        mozoPopupErrorView?.center = view.center
        self.view.addSubview(self.mozoPopupErrorView!)
    }
    
    func removeMozoPopupError() {
        DispatchQueue.main.async {
            self.mozoPopupErrorView?.removeFromSuperview()
        }
    }
    
    // MARK: Popup Token Expired
    var mozoPopupTokenExpired: MozoPopupTokenExpired?
    
    func displayMozoPopupTokenExpired() {
        mozoPopupTokenExpired = MozoPopupTokenExpired(frame: CGRect(x: 0, y: 0, width: 222, height: 193))
        
        mozoPopupTokenExpired?.clipsToBounds = false
        mozoPopupTokenExpired?.dropShadow()
        mozoPopupTokenExpired?.containerView.roundCorners(borderColor: .white, borderWidth: 1)
        
        mozoPopupTokenExpired?.center = view.center
        
        mozoPopupTokenExpired?.modalCloseHandler = {
            self.mozoPopupTokenExpired?.removeFromSuperview()
        }
        self.view.addSubview(self.mozoPopupTokenExpired!)
    }
    
    func removeMozoPopupTokenExpired() {
        DispatchQueue.main.async {
            self.mozoPopupTokenExpired?.removeFromSuperview()
        }
    }
}
