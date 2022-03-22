//
//  ExpandImageCollectionViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/23/19.
//

import Foundation
import UIKit
import SDWebImage

class ExpandImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var imageName: String? {
        didSet {
            bindData()
        }
    }
    var isZooming = false
    var originalImageCenter: CGPoint?
    
    override func awakeFromNib() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(pinchGesture)
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
    }
    
    func bindData() {
        imageView.transform = .identity
        if let imageName = self.imageName, !imageName.isEmpty {
            imageView.load(imageName, placeHolder: "")
        } else {
            imageView.image = nil
        }
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1, scale.a < 5, scale.d < 5 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
    
    class func register(_ collectionView: UICollectionView) {
        collectionView.register(
            UINib.init(nibName: "ExpandImageCollectionViewCell", bundle: BundleManager.mozoBundle()),
            forCellWithReuseIdentifier: "ExpandImageCollectionViewCell"
        )
    }
}
