//
//  ResetPINViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/8/19.
//

import Foundation
class ResetPINViewController: MozoBasicViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lbExplain: UILabel!
    @IBOutlet weak var mnemonicsView: MnemonicsView!
    
    var eventHandler: ResetPINModuleInterface?
    
    var submitButton: UIBarButtonItem!
    
    var waitingView: MozoWaitingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        setupWaitingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Reset PIN".localized
        addSubmitBtn()
    }
    
    func addSubmitBtn() {
        print("ResetPINViewController - Add submit bar button.")
        submitButton = UIBarButtonItem(title: "Submit".localized, style: .plain, target: self, action: #selector(self.touchSubmitBarButton))
        submitButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = submitButton
    }
    
    func setupWaitingView() {
        waitingView = MozoWaitingView(frame: self.view.frame)
        self.view.addSubview(waitingView)
        waitingView.isHidden = true
    }
    
    @objc func touchSubmitBarButton() {
        print("ResetPINViewController - touchNextBarButton")
        eventHandler?.resetPINWithMnemonics(self.mnemonicsView.mnemonics)
    }
    
    func enableSubmitButton(_ enable: Bool = true) {
        self.submitButton.isEnabled = enable
    }
    
    @IBAction func mnemonicChange(_ sender: Any) {
        print("ResetPINViewController - mnemonicChange: \(self.mnemonicsView.mnemonics)")
        eventHandler?.checkMnemonics(self.mnemonicsView.mnemonics)
    }
}
extension ResetPINViewController: ResetPINViewInterface {
    func allowGoNext() {
        enableSubmitButton()
        
        lbExplain.text = "Type your 12 recover phrases".localized
        lbExplain.textColor = UIColor(hexString: "333333")
    }
    
    func disallowGoNext() {
        enableSubmitButton(false)
        
        lbExplain.text = "Recovery phrase contains unrecognized words.".localized
        lbExplain.textColor = UIColor(hexString: "f05454")
    }
    
    func mnemonicsNotBelongToUserWallet() {
        enableSubmitButton()
        lbExplain.text = "Recovery phrase is not belong to your wallet.".localized
        lbExplain.textColor = UIColor(hexString: "f05454")
    }
    
    func displayWaiting(isChecking: Bool) {
        waitingView.isHidden = false
        enableSubmitButton(false)
        if isChecking {
            // Checking recovery phrases
            waitingView.lbExplain.text = "Checking recovery phrases".localized
        } else {
            // Reset PIN is processing
            waitingView.lbExplain.text = "Reset PIN is processing".localized
        }
        waitingView.stopRotating = false
        waitingView.rotateView()
    }
    
    func closeWaiting(clearData: Bool) {
        waitingView.isHidden = true
        waitingView.stopRotating = true
        
        if clearData {
            // TODO: Clear data after maintenance mode
            self.mnemonicsView.clearAllTextFields()
        }
    }
}
