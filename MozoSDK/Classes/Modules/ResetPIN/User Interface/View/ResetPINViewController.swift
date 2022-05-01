//
//  ResetPINViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/8/19.
//

import Foundation
import web3swift

class ResetPINViewController: MozoBasicViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lbExplain: UILabel!
    @IBOutlet weak var input1: UITextField!
    @IBOutlet weak var input1_line: UIView!
    @IBOutlet weak var input2: UITextField!
    @IBOutlet weak var input2_line: UIView!
    @IBOutlet weak var input3: UITextField!
    @IBOutlet weak var input3_line: UIView!
    @IBOutlet weak var input4: UITextField!
    @IBOutlet weak var input4_line: UIView!
    @IBOutlet weak var input5: UITextField!
    @IBOutlet weak var input5_line: UIView!
    @IBOutlet weak var input6: UITextField!
    @IBOutlet weak var input6_line: UIView!
    @IBOutlet weak var input7: UITextField!
    @IBOutlet weak var input7_line: UIView!
    @IBOutlet weak var input8: UITextField!
    @IBOutlet weak var input8_line: UIView!
    @IBOutlet weak var input9: UITextField!
    @IBOutlet weak var input9_line: UIView!
    @IBOutlet weak var input10: UITextField!
    @IBOutlet weak var input10_line: UIView!
    @IBOutlet weak var input11: UITextField!
    @IBOutlet weak var input11_line: UIView!
    @IBOutlet weak var input12: UITextField!
    @IBOutlet weak var input12_line: UIView!
    
    private let MAX_INPUT: Int = 12
    private lazy var words: [String] = {
        return BIP39Language.english.words
    }()
    
    var eventHandler: ResetPINModuleInterface?
    
    var submitButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var waitingView: MozoWaitingView!
    
    var keyboardHeight: CGFloat = 0
    var keyboardWasShown = false
        
    var isWaiting = false
    var isDisplayingTryAgain = false {
        didSet {
            if submitButton != nil {
                if isDisplayingTryAgain {
                    navigationItem.hidesBackButton = true
                    self.navigationItem.rightBarButtonItem = cancelButton
                } else {
                    navigationItem.hidesBackButton = false
                    self.navigationItem.rightBarButtonItem = submitButton
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        setupCancelBtn()
        setupWaitingView()
        
        input1.delegate = self
        input2.delegate = self
        input3.delegate = self
        input4.delegate = self
        input5.delegate = self
        input6.delegate = self
        input7.delegate = self
        input8.delegate = self
        input9.delegate = self
        input10.delegate = self
        input11.delegate = self
        input12.delegate = self
        input12.addTarget(self, action: #selector(checkSeed), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Reset PIN".localized
        addSubmitBtn()
        setupKeyboardEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input1.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        let allowedCharacters = CharacterSet.letters
        let characterSet = CharacterSet(charactersIn: string)
        return count <= MAX_INPUT && allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .darkText
        let lineColor: UIColor = .systemBlue
        switch textField {
        case input1:
            input1_line.backgroundColor = lineColor
            break
        case input2:
            input2_line.backgroundColor = lineColor
            break
        case input3:
            input3_line.backgroundColor = lineColor
            break
        case input4:
            input4_line.backgroundColor = lineColor
            break
        case input5:
            input5_line.backgroundColor = lineColor
            break
        case input6:
            input6_line.backgroundColor = lineColor
            break
        case input7:
            input7_line.backgroundColor = lineColor
            break
        case input8:
            input8_line.backgroundColor = lineColor
            break
        case input9:
            input9_line.backgroundColor = lineColor
            break
        case input10:
            input10_line.backgroundColor = lineColor
            break
        case input11:
            input11_line.backgroundColor = lineColor
            break
        case input12:
            input12_line.backgroundColor = lineColor
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text?.lowercased().trim() ?? ""
        let isContains = value.isEmpty || words.contains(value)
        let textColor: UIColor = isContains ? .systemBlue : .systemRed
        textField.textColor = textColor
        
        let lineColor: UIColor = .systemGray
        switch textField {
        case input1:
            input1_line.backgroundColor = lineColor
            break
        case input2:
            input2_line.backgroundColor = lineColor
            break
        case input3:
            input3_line.backgroundColor = lineColor
            break
        case input4:
            input4_line.backgroundColor = lineColor
            break
        case input5:
            input5_line.backgroundColor = lineColor
            break
        case input6:
            input6_line.backgroundColor = lineColor
            break
        case input7:
            input7_line.backgroundColor = lineColor
            break
        case input8:
            input8_line.backgroundColor = lineColor
            break
        case input9:
            input9_line.backgroundColor = lineColor
            break
        case input10:
            input10_line.backgroundColor = lineColor
            break
        case input11:
            input11_line.backgroundColor = lineColor
            break
        case input12:
            input12_line.backgroundColor = lineColor
            break
        default:
            break
        }
        
        self.checkSeed()
    }
    
    func setupKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        keyboardWasShown = true
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero).size
        keyboardHeight = keyboardSize.height
        updateScrollViewInsets()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardWasShown {
            let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero).size;
            keyboardHeight = keyboardSize.height
            updateScrollViewInsets()
        }
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        keyboardWasShown = false
        keyboardHeight = 0.0
        updateScrollViewInsets()
    }
    
    func addSubmitBtn() {
        submitButton = UIBarButtonItem(title: "Submit".localized, style: .plain, target: self, action: #selector(self.touchSubmitBarButton))
        submitButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = submitButton
    }
    
    func setupCancelBtn() {
        cancelButton = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: #selector(self.touchCancelBarButton))
        cancelButton.isEnabled = true
    }
    
    func setupWaitingView() {
        waitingView = MozoWaitingView(frame: self.view.frame)
        self.view.addSubview(waitingView)
        waitingView.isHidden = true
    }
    
    func removePopupTryAgain() {
        if let errorPopup = view.subviews.last as? MozoPopupErrorView {
            errorPopup.delegate = nil
        }
    }
    
    func requestCancel() {
        removePopupTryAgain()
        if let navigationController = self.navigationController as? MozoNavigationController, let coreEventHandler = navigationController.coreEventHandler {
            coreEventHandler.requestForCloseAllMozoUIs(nil)
        }
    }
    
    @objc func touchCancelBarButton() {
        requestCancel()
    }
    
    @objc func touchSubmitBarButton() {
        if isDisplayingTryAgain {
            requestCancel()
        } else {
            let mnemonics = mergeSeed()
            eventHandler?.resetPINWithMnemonics(mnemonics)
        }
    }
    
    func enableSubmitButton(_ enable: Bool = true) {
        self.submitButton.isEnabled = enable
    }
    
    func updateScrollViewInsets() {
        let bottomInset : CGFloat = keyboardHeight > 0 ? 258 : 0
        var insets = self.scrollView.contentInset
        if #available(iOS 11.0, *) {
            insets = self.scrollView.adjustedContentInset
        }
        insets.bottom = keyboardHeight
        if #available(iOS 11.0, *) {
//            insets.bottom -= self.view.safeAreaInsets.bottom
            insets.bottom = bottomInset
        }
        insets.top = 0.0
        self.scrollView.contentInset = insets
        
        var indicatorInset = self.scrollView.scrollIndicatorInsets
        indicatorInset.bottom = keyboardHeight
        if #available(iOS 11.0, *) {
             indicatorInset.bottom = bottomInset
        }
        self.scrollView.scrollIndicatorInsets = indicatorInset
    }
    
    private func mergeSeed() -> String {
        let inputs: [UITextField] = [input1, input2, input3, input4, input5, input6, input7, input8, input9, input10, input11, input12]
        let seed = inputs.compactMap{ ($0.text ?? "").isEmpty ? nil : $0.text }.joined(separator: " ")
        return seed.lowercased()
    }
    
    @objc private func checkSeed() {
        let seed = mergeSeed()
        eventHandler?.checkMnemonics(seed)
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
        lbExplain.text = "Wallet Recovery Phrase is invalid".localized
        lbExplain.textColor = UIColor(hexString: "f05454")
    }
    
    func displayWaiting(isChecking: Bool) {
        isDisplayingTryAgain = false
        
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
//        waitingView.rotateView()
    }
    
    func closeWaiting(clearData: Bool, displayTryAgain: Bool) {
        isDisplayingTryAgain = displayTryAgain
        if displayTryAgain {
            self.view.endEditing(true)
        }
        
        waitingView.isHidden = true
        waitingView.stopRotating = true
        
        if clearData {
            [
                input1, input2, input3, input4, input5, input6, input7, input8, input9, input10, input11, input12
            ].forEach { $0.text = nil }
        }
    }
}
