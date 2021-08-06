//
//  AddressBookView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/19.
//

import Foundation
protocol AddressBookViewDelegate {
    func didTouchClear()
    func openContactDetails(_ id: Int64, _ isStoreContact: Bool)
}
@IBDesignable class AddressBookView: MozoView {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPhone: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    
    var delegate: AddressBookViewDelegate?
    
    var addressBook: AddressBookDisplayItem? {
        didSet {
            bindData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchedRoot))
        tap.numberOfTapsRequired = 1
        containView.isUserInteractionEnabled = true
        containView.addGestureRecognizer(tap)
    
    }
    
    func bindData() {
        if let addressBook = self.addressBook {
            let imgName = addressBook.isStoreBook ? "ic_store_profile" : "ic_user_profile"
            let img = UIImage(named: imgName, in: BundleManager.mozoBundle(), compatibleWith: nil)
            userImageView.image = img
            
            var height: CGFloat = 60
            if addressBook.name.isEmpty {
                lbName.isHidden = true
                height = 45
            } else {
                lbName.isHidden = false
                lbName.text = addressBook.name
            }
            lbAddress.text = addressBook.address
            let middleText = addressBook.isStoreBook ? addressBook.physicalAddress : addressBook.phoneNo
            if middleText.isEmpty {
                lbPhone.isHidden = true
                height = 45
                if addressBook.address.isEmpty {
                    height = 20
                }
            } else {
                lbPhone.isHidden = false
                lbPhone.text = middleText
            }
            
            stackViewHeightConstraint.constant = height
        }
    }
    
    @IBAction func touchBtnClear(_ sender: Any?) {
        delegate?.didTouchClear()
    }
    
    @objc func touchedRoot() {
        if let id = addressBook?.id {
            delegate?.openContactDetails(id, addressBook?.isStoreBook == true)
        }
    }
}
