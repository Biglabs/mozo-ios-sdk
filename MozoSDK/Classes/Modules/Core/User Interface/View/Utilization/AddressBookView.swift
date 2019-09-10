//
//  AddressBookView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/19.
//

import Foundation
protocol AddressBookViewDelegate {
    func didTouchClear()
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
        setupLayout()
    }
    
    func setupLayout() {
        //ic_user_profile
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
}
