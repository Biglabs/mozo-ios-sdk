//
//  StoreBookTableViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/12/19.
//

import Foundation
let STORE_BOOK_TABLE_VIEW_CELL_IDENTIFIER = "StoreBookTableViewCell"
class StoreBookTableViewCell: UITableViewCell {
    @IBOutlet weak var lbStoreName: UILabel?
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var lbPhysicalAddress: UILabel?
    @IBOutlet weak var lbOffchainAddress: UILabel?
    
    var displayItem: AddressBookDisplayItem? {
        didSet {
            bindData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    func bindData() {
        if let displayData = self.displayItem {
            lbStoreName?.text = displayData.name
            lbPhysicalAddress?.text = displayData.physicalAddress
            lbOffchainAddress?.text = displayData.address
        }
    }
    
    func updateLayout() {
        let image = UIImage(named: "ic_pin", in: BundleManager.mozoBundle(), compatibleWith: nil)
        imgView?.image = image?.withRenderingMode(.alwaysTemplate)
        imgView?.tintColor = UIColor(hexString: "9b9b9b")
    }
}
