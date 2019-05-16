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
    
    var keyboardHeight: CGFloat = 0
    var keyboardWasShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        setupWaitingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Reset PIN".localized
        addSubmitBtn()
        setupKeyboardEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.mnemonicsView.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        print("viewSafeAreaInsetsDidChange")
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        updateScrollViewInsets()
    }
    
    func setupKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("Keyboard will show")
        keyboardWasShown = true
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero).size
        keyboardHeight = keyboardSize.height
        updateScrollViewInsets()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("Keyboard will hide")
        if keyboardWasShown {
            let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero).size;
            keyboardHeight = keyboardSize.height
            updateScrollViewInsets()
        }
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        print("Keyboard will change frame")
        keyboardWasShown = false
        keyboardHeight = 0.0
        updateScrollViewInsets()
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
    
    func updateScrollViewInsets() {
        print("Update scroll view insets, keyboard height: \(keyboardHeight)")
        let bottomInset : CGFloat = keyboardHeight > 0 ? 258 : 0
        var insets = self.scrollView.contentInset
        if #available(iOS 11.0, *) {
            insets = self.scrollView.adjustedContentInset
        }
        insets.bottom = keyboardHeight
        if #available(iOS 11.0, *) {
            print("Update scroll view insets, safeAreaInsets bottom: \(self.view.safeAreaInsets.bottom)")
//            insets.bottom -= self.view.safeAreaInsets.bottom
            insets.bottom = bottomInset
        }
        insets.top = 0.0
        print("Insets, top [\(insets.top)], bottom [\(insets.bottom)]")
        self.scrollView.contentInset = insets
        
        var indicatorInset = self.scrollView.scrollIndicatorInsets
        indicatorInset.bottom = keyboardHeight
        if #available(iOS 11.0, *) {
//            indicatorInset.bottom -= self.view.safeAreaInsets.bottom
            indicatorInset.bottom = bottomInset
        }
        print("Indicator Insets, top [\(indicatorInset.top)], bottom [\(indicatorInset.bottom)]")
        self.scrollView.scrollIndicatorInsets = indicatorInset
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
            print("Clear data after maintenance mode")
            self.mnemonicsView.clearAllTextFields()
        }
    }
}
