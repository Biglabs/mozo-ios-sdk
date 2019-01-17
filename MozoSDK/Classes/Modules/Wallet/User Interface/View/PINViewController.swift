//
//  PINViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit

class PINViewController : MozoBasicViewController {
    @IBOutlet weak var pinTextField: PinTextField!
    @IBOutlet weak var enterPINLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var confirmImg: UIImageView!
    
    var eventHandler : WalletModuleInterface?
    var passPhrase : String?
    var moduleRequested: Module = .Wallet
    
    private var pin : String?
    private var isConfirm = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        pinTextField.becomeFirstResponder()
        pinTextField.delegate = self as PinTextFieldDelegate
        pinTextField.keyboardType = .numberPad
        if self.passPhrase == nil {
            title = "Enter Security PIN".localized
            if moduleRequested == Module.Transaction {
                enterPINLabel.text = "Enter your Security PIN\nto send MozoX".localized
                descriptionLabel.text = "Security PIN must be 6 digits".localized
            } else {
                // Enter new pin and confirm new pin
                enterPINLabel.text = "Enter your Security PIN\nto restore wallet".localized
            }
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension PINViewController: PinTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinTextField) -> Bool {
        return true
    }
    
    func textFieldValueChanged(_ textField: PinTextField) {
        let value = textField.text ?? ""
        print("value changed: \(value)")
    }
    
    func textFieldShouldEndEditing(_ textField: PinTextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: PinTextField) {
        pinInputComplete(input: textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: PinTextField) -> Bool {
        return true
    }
}

extension PINViewController : PINViewInterface {
    func displayErrorAndLogout(_ error: ErrorApiResponse) {
        displayMozoAlertInfo(infoMessage: error.description) {
            MozoSDK.logout()
        }
    }
    
    func showCreatingInterface() {
        validationSuccess()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(900)) {
            self.hideAllUIs()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.eventHandler?.manageWallet(passPhrase: self.passPhrase, pin: self.pin!)
        }
    }
    
    func showVerificationFailed() {
        validationFail()
    }
    
    func showConfirmPIN() {
        pinTextField.text = ""
        enterPINLabel.text = "Confirm Security PIN".localized
        descriptionLabel.text = "Re-enter your PIN".localized
        confirmImg.isHidden = false
        isConfirm = true
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner(hidesBackButton: true)
    }
    
    func displayTryAgain(_ error: ConnectionError) {
        displayMozoPopupError(error)
        mozoPopupErrorView?.delegate = self
    }
}
extension PINViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        
    }
    
    func didTouchTryAgainButton() {
        print("User try manage wallet again.")
        removeMozoPopupError()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.eventHandler?.manageWallet(passPhrase: self.passPhrase, pin: self.pin!)
        }
    }
}
private extension PINViewController {
    func hideAllUIs() {
        self.view.endEditing(true)
        view.subviews.forEach({ $0.isHidden = true })
        enterPINLabel.isHidden = false
        showActivityIndicator()
    }
    
    func showActivityIndicator() {
        var activityIndicator = UIActivityIndicatorView()
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        
        effectView.frame = CGRect(x: view.frame.midX - 23, y: view.frame.midY - 23, width: 46, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = ThemeManager.shared.main
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        view.addSubview(effectView)
    }
    
    func pinInputComplete(input: String) {
        if !isConfirm {
            pin = input
            if self.passPhrase != nil {
                eventHandler?.enterPIN(pin: input)
            } else {
                // TODO: Should handle freeze UI here
                eventHandler?.verifyPIN(pin: input)
            }
        } else {
            eventHandler?.verifyConfirmPIN(pin: pin!, confirmPin: input)
        }
    }
    
    func validationSuccess() {
        print("😍 success!")
        statusImg.isHidden = false
        statusLabel.isHidden = false
        confirmImg.isHighlighted = true
        pinTextField.isUserInteractionEnabled = false
        if !isConfirm {
            statusLabel.text = "You entered a correct PIN".localized
        } else {
            statusLabel.text = "Create Security PIN successfully".localized
        }
        statusLabel.textColor = ThemeManager.shared.success
    }
    
    func validationFail() {
        print("😞 failure!")
        statusImg.isHidden = true
        statusLabel.isHidden = false
        statusLabel.text = "You entered an incorrect PIN".localized
        statusLabel.textColor = ThemeManager.shared.error
    }
}
