//
//  AutoPINViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/19/19.
//

import Foundation
class AutoPINViewController: MozoBasicViewController {
    var waitingView: MozoWaitingView!
    
    var checkView: UIView!
    var checkImg: UIImageView!
    var checkLabel: UILabel!
    var btnCheck: UIButton!
    
    var isChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWaitingView()
        setupCheckView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupWaitingView() {
        waitingView = MozoWaitingView(frame: self.view.frame)
        self.view.addSubview(waitingView)
        waitingView.rotateView()
        waitingView.lbExplain.text = "System is using automatically generated PIN to sign your transaction and send it to network...".localized
    }
    
    func setupCheckView() {
        checkView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        checkView.roundCorners(borderColor: ThemeManager.shared.main, borderWidth: 2)
        checkView.translatesAutoresizingMaskIntoConstraints = false
        
        checkImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkImg.roundCorners(cornerRadius: 0.5, borderColor: ThemeManager.shared.main, borderWidth: 2)
        checkImg.highlightedImage = UIImage(named: "ic_check", in: BundleManager.mozoBundle(), compatibleWith: nil)
        checkImg.isHighlighted = false
        checkImg.translatesAutoresizingMaskIntoConstraints = false
        
        checkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: checkView.frame.width, height: 50))
        checkLabel.text = "Don’t show again".localized
        checkLabel.textColor = ThemeManager.shared.main
        checkLabel.font = UIFont.systemFont(ofSize: 13)
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        
        btnCheck = UIButton(frame: checkView.frame)
        btnCheck.backgroundColor = .clear
        btnCheck.addTarget(self, action: #selector(touchBtnCheck), for: .touchUpInside)
        btnCheck.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(checkView)
        checkView.addSubview(checkImg)
        checkView.addSubview(checkLabel)
        checkView.addSubview(btnCheck)
        
        view.addConstraints([
            NSLayoutConstraint(item: checkView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: checkView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -30),
            NSLayoutConstraint(item: checkView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: -80),
            NSLayoutConstraint(item: checkView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50),
            
            NSLayoutConstraint(item: checkLabel, attribute: .centerY, relatedBy: .equal, toItem: self.checkView, attribute: .centerY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: checkLabel, attribute: .centerX, relatedBy: .equal, toItem: self.checkView, attribute: .centerX, multiplier: 1.0, constant: 15),
            
            NSLayoutConstraint(item: checkImg, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 30),
            NSLayoutConstraint(item: checkImg, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 30),
            NSLayoutConstraint(item: checkImg, attribute: .centerY, relatedBy: .equal, toItem: self.checkView, attribute: .centerY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: checkImg, attribute: .trailing, relatedBy: .equal, toItem: self.checkLabel, attribute: .leading, multiplier: 1.0, constant: -10),
            
            NSLayoutConstraint(item: btnCheck, attribute: .top, relatedBy: .equal, toItem: self.checkView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: btnCheck, attribute: .bottom, relatedBy: .equal, toItem: self.checkView, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: btnCheck, attribute: .leading, relatedBy: .equal, toItem: self.checkView, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: btnCheck, attribute: .trailing, relatedBy: .equal, toItem: self.checkView, attribute: .trailing, multiplier: 1.0, constant: 0),
            ])
    }
    
    @objc func touchBtnCheck() {
        isChecked = !isChecked
        checkImg.isHighlighted = isChecked
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            SessionStoreManager.saveNotShowAutoPINScreen(isChecked)
            waitingView.stopRotating = true
            navigationController?.isNavigationBarHidden = false
        }
    }
}
