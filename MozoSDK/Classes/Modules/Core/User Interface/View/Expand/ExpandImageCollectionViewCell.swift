//
//  ExpandImageCollectionViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/23/19.
//

import Foundation
import UIKit
let EXPAND_IMAGE_COLLECTION_VIEW_CELL_IDENTIFIER = "ExpandImageCollectionViewCell"
class ExpandImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: CustomImageView!
    
    var imageName: String? {
        didSet {
            bindData()
        }
    }
    
    func bindData() {
        if let imageName = self.imageName, !imageName.isEmpty {
            let url = "\(Configuration.DOMAIN_IMAGE)\(imageName)"
            let paramUrlString = "\(url)?width=\(Int(self.frame.width * UIScreen.main.scale * 2))&height=\(Int(self.frame.height * UIScreen.main.scale * 2))"
            imageView.imageUrlString = paramUrlString
            imageView.loadImageUsingUrlString(paramUrlString, defaultImageName: "", isShowLoading: true, isUseScreenCenter: true)
        } else {
            imageView.image = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
