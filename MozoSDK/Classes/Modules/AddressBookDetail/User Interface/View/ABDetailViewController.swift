//
//  ABDetailViewController.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation

class ABDetailViewController : MozoBasicViewController {
    var eventHandler : ABDetailModuleInterface?
    
    @IBOutlet var txtName : UITextField!
    @IBOutlet weak var nameBorderView: UIView!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var addressBorderView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var successView: UIView!
    
    var transitioningBackgroundView : UIView = UIView()
    var address : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Add New Address".localized
    }
    
    func updateView() {
        txtAddress.text = address
        txtName.delegate = self
        txtName.addTarget(self, action: #selector(textFieldNameDidBeginEditing), for: UIControlEvents.editingDidBegin)
        txtName.addTarget(self, action: #selector(textFieldNameDidEndEditing), for: UIControlEvents.editingDidEnd)
        addDoneButtonOnKeyboard()
    }
    
    @objc func textFieldNameDidBeginEditing() {
        print("TextFieldNameDidBeginEditing")
        setHighlightNameTextField(isHighlighted: true)
    }
    
    @objc func textFieldNameDidEndEditing() {
        print("TextFieldNameDidEndEditing")
        setHighlightNameTextField(isHighlighted: false)
    }
    
    func setHighlightNameTextField(isHighlighted: Bool) {
        nameBorderView.backgroundColor = isHighlighted ? ThemeManager.shared.main : ThemeManager.shared.disable
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.txtName.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        txtName.resignFirstResponder()
    }
    
    @IBAction func save(_ sender: AnyObject) {
        if let text = txtName.text {
            let trim = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trim.isEmpty {
                displayMozoError("Name can not be empty")
                return
            }
            eventHandler?.saveAddressBookWithName(trim, address: address!)
        } else {
            displayMozoError("Name can not be empty")
        }
    }
    
    @IBAction func endEditing(_ sender: Any) {
        // Check to enable button save
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        txtName.resignFirstResponder()
        eventHandler?.cancelSaveAction()
    }
}

extension ABDetailViewController: ABDetailViewInterface {
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func displaySuccess() {
        self.successView.isHidden = false
        self.txtName.isEnabled = false
        self.btnSave.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.eventHandler?.finishSaveAddressBook()
        }
    }
}

extension ABDetailViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= Configuration.MAX_NAME_LENGTH
    }
}
