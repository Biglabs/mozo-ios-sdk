//
//  AddressBookTableViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
class AddressBookTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPhone: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    
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
            var height: CGFloat = 60
            lbName.text = addressBook.name
            lbAddress.text = addressBook.address
            if addressBook.phoneNo.isEmpty {
                lbPhone.isHidden = true
                height = 45
            } else {
                lbPhone.isHidden = false
                lbPhone.text = addressBook.phoneNo
            }
            
            stackViewHeightConstraint.constant = height
        }
    }
}
