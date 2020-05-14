//
//  ABEditViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation

class ABEditViewController : MozoBasicViewController {
    var eventHandler : ABEditModuleInterface?
    var displayItem: AddressBookDisplayItem?
    
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var lbAddress: CopyableLabel!
    
    var saveBtn : UIBarButtonItem?
    
    var retryForDelete: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        updateView()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Address Detail".localized
    }
    
    func updateView() {
        nameTextView.delegate = self
        addSaveButtonOnKeyboard()
        if let item = displayItem {
            nameTextView.text = item.name
            lbAddress.text = item.address
        }
    }
    
    func addSaveButtonOnKeyboard()
    {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        toolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        saveBtn = UIBarButtonItem(title: "Save changes".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(saveButtonAction))
        
        toolbar.items = [flexSpace, saveBtn!]
        toolbar.sizeToFit()
        
        nameTextView.inputAccessoryView = toolbar
        saveBtn?.isEnabled = false
    }
    
    @objc func saveButtonAction()
    {
        nameTextView.resignFirstResponder()
        if let item = displayItem {
            eventHandler?.requestUpdateAddressBook(item, updateName: nameTextView.text)
        }
    }
    
    func displayConfirm(_ item: AddressBookDisplayItem) {
        displayMozoAlertConfirm(confirmCompletion: {
            self.eventHandler?.requestDeleteAddressBook(item)
        }, notConfirmCompletion: nil)
    }
    
    @IBAction func touchedBtnDelete(_ sender: Any) {
        if let item = displayItem {
            displayConfirm(item)
        }
    }
    
    @IBAction func touchedBtnEdit(_ sender: Any) {
        nameTextView.becomeFirstResponder()
    }
}
extension ABEditViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let viewText = textView.text else { return true }
        let count = viewText.count + text.count - range.length
        return count <= Configuration.MAX_NAME_LENGTH
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, let item = displayItem {
            if text != item.name {
                saveBtn?.isEnabled = true
                return
            }
        }
        saveBtn?.isEnabled = false
    }
}
extension ABEditViewController : ABEditViewInterface {
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
    }
    
    func displaySuccess() {
        displayMozoAlertSuccess {
            self.eventHandler?.finishEditAddressBook()
        }
    }
    
    func displayTryAgain(_ error: ConnectionError, forDelete: Bool) {
        retryForDelete = forDelete
        DisplayUtils.displayTryAgainPopup(error: error, delegate: self)
    }
}
extension ABEditViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        
    }
    
    func didTouchTryAgainButton() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            if self.retryForDelete == true {
                print("User try delete address book again.")
                self.eventHandler?.requestDeleteAddressBook(self.displayItem!)
            } else {
                print("User try update address book again.")
                self.eventHandler?.requestUpdateAddressBook(self.displayItem!, updateName: self.nameTextView.text)
            }
        }
    }
}
