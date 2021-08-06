//
//  PaymentQRViewController+AddressBook.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/19.
//

import Foundation
extension PaymentQRViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dropdown.width = addressLine.bounds.width
    }
    
    func setupAddressBook() {
        abEmptyDropDownView.delegate = self
        addressBookView.delegate = self
        addressBookView.btnClear.isHidden = false
    }
    
    func setupDropdown() {
        print("PaymentQRViewController - Setup dropdown")
        dropdown.dismissMode = .automatic
        dropdown.direction = .bottom
        dropdown.dropDownHeight = 247
        
        dropdown.cellHeight = 80
        dropdown.backgroundColor = .white
        dropdown.separatorColor = .white
        dropdown.cornerRadius = 0
        dropdown.shadowColor = UIColor(hexString: "a8c5ec")
        dropdown.shadowOffset = CGSize(width: 0, height: 8)
        dropdown.shadowSpread = 8
        dropdown.shadowRadius = 4
        dropdown.animationduration = 0.25
        dropdown.textColor = UIColor(hexString: "4a4a4a")
        dropdown.textFont = UIFont.systemFont(ofSize: 15)
        
        if #available(iOS 11.0, *) {
            dropdown.setupMaskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        }
        
        dropdown.cellNib = UINib(nibName: String(describing: ABDropDownCell.self), bundle: BundleManager.mozoBundle())
        dropdown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? ABDropDownCell else { return }
            let addressBook = self.filteredCollection.addressBookItemFromId(Int64(item) ?? 0)
            cell.abView.addressBook = addressBook
        }
        
        dropdown.anchorView = addressLine
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        dropdown.bottomOffset = CGPoint(x: 0, y: addressLine.bounds.height + 6)
        
        // Action triggered on selection
        dropdown.selectionAction = { [weak self] (index, item) in
            if let addressBook = self?.filteredCollection.displayItems[index] {
                self?.displayContactItem = addressBook
                self?.txtAddressOrPhoneNo.resignFirstResponder()
            }
        }
    }
    
    func updateAddressBookOnUI() {
        if let addressBook = self.displayContactItem {
            addressContainerView.isHidden = true
            
            addressBookView.isHidden = false
            addressBookView.addressBook = addressBook
            btnAddressBookTopConstraint.constant = topSpaceWithAB
        } else {
            addressContainerView.isHidden = false
            
            addressLine.backgroundColor = txtAddressOrPhoneNo.isEditing ? ThemeManager.shared.main : ThemeManager.shared.disable
            addressBookView.isHidden = true
            btnAddressBookTopConstraint.constant = topSpace
        }
        
        checkDisableButtonSend()
    }
    
    func updateDropDownDataSource() {
        let inputValue = txtAddressOrPhoneNo.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        if inputValue.isEmpty {
            dropdown.dataSource = []
            abEmptyDropDownView.isHidden = true
            dropdown.hide()
            return
        }
        
        var items = [AddressBookDTO]()
        let text = inputValue.lowercased()
        if !text.isEmpty {
            items = SafetyDataManager.shared.addressBookList.filter({ ($0.name?.lowercased() ?? "").contains(text) || ($0.phoneNo?.lowercased() ?? "").contains(text) || ($0.soloAddress?.lowercased() ?? "").contains(text) })
        }
        filteredCollection = AddressBookDisplayCollection(items: items)
        filteredCollection.sortByName()
        
        let dataSource = filteredCollection.displayItems.map({ String($0.id)})
        dropdown.dataSource = dataSource
        if dataSource.isEmpty {
            if inputValue.isEthAddress() {
                abEmptyDropDownView.isHidden = true
            } else {
                abEmptyDropDownView.isHidden = false
            }
            dropdown.hide()
        } else {
            abEmptyDropDownView.isHidden = true
            dropdown.show()
        }
    }
    
    func validatePhoneNoAfterFinding() {
        // Check empty
        let inputValue = txtAddressOrPhoneNo.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        if inputValue.isEmpty {
            return
        }
        let hasPrefixWith0X = inputValue.hasPrefix("0x")
        if hasPrefixWith0X {
            return
        }
        // Check type of text: Phone Number or Plain Text
        if !inputValue.isValidPhoneNumber() {
            self.displayError("We only support to search with phone number.")
            return
        }
        if inputValue.hasPrefix("+"), countryData.findCountryByText(inputValue) == nil {
            self.displayError("Invalid country code")
            return
        }
        if inputValue.hasPrefix("0") {
            eventHandler?.findContact(inputValue)
            return
        }
        if let country = countryData.findCountryByText(inputValue) {
            if let nbPhoneNumber = try? nbPhoneNumberUtil.parse(inputValue, defaultRegion: country.countryCode) {
                if !nbPhoneNumberUtil.isValidNumber(nbPhoneNumber) {
                    self.displayError("Invalid phone number")
                    return
                }
                eventHandler?.findContact(inputValue)
            } else {
                self.displayError("Invalid phone number")
            }
        } else {
            self.displayError("Invalid country code")
        }
    }
}
extension PaymentQRViewController: ABEmptyDropDownViewDelegate {
    func didTouchFindInMozoXSystem() {
        doneButtonActionForAddressOrPhone()
    }
}
extension PaymentQRViewController: AddressBookViewDelegate {
    func didTouchClear() {
        displayContactItem = nil
        txtAddressOrPhoneNo.text = ""
    }
    
    func openContactDetails(_ id: Int64, _ isStoreContact: Bool) {
    }
}
extension PaymentQRViewController {
    func notFoundContact(_ phoneNo: String) {
        displayMozoError("text_msg_phone_not_belong_any_wallet")
    }
}
