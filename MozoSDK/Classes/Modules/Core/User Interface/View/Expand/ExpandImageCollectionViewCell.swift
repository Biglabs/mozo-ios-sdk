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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var imageName: String? {
        didSet {
            bindData()
        }
    }
    var isZooming = false
    var originalImageCenter: CGPoint?
    
    func bindData() {
        imageView.transform = .identity
        
        if let imageName = self.imageName, !imageName.isEmpty {
            loadingIndicator.startAnimating()
            let url = "\(Configuration.DOMAIN_IMAGE)\(imageName)"
            imageView.loadImage(url, defaultImageName: "") {
                self.loadingIndicator?.stopAnimating()
            }
        } else {
            imageView.image = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1, scale.a < 5, scale.d < 5 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}
