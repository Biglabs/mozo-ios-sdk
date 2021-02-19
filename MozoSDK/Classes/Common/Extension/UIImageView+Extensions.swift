//
//  UIImageView+Extensions.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import Kingfisher

let imageCache = NSCache<NSString, AnyObject>()
public extension UIImageView {
    func load(_ url: String?) {
        let placeHolder = UIImage(named: "ic_store_profile", in: BundleManager.mozoBundle(), compatibleWith: nil)
        if let safeUrl = url, !safeUrl.isEmpty {
            var finalUrl = safeUrl
            if !safeUrl.starts(with: "http") {
                finalUrl = "\(Configuration.DOMAIN_IMAGE)\(safeUrl)?width=\(Int(self.frame.width * UIScreen.main.scale * 2))&height=\(Int(self.frame.height * UIScreen.main.scale * 2))"
            }
            
            self.kf.setImage(
                with: URL(string: finalUrl)!,
                placeholder: placeHolder,
                options: [
                    .processor(DownsamplingImageProcessor(size: self.frame.size)),
                    .scaleFactor(UIScreen.main.scale * 2),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]
            )
        } else {
            image = placeHolder
        }
    }
    
    func loadImage(_ urlString: String, defaultImageName: String = "img_store_no_img",
                   isDefaultImageFromMozo: Bool = false) {
        let placeHolderImage = isDefaultImageFromMozo ? UIImage(named: defaultImageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
            : UIImage(named: defaultImageName)
        let paramUrlString = "\(urlString)?width=\(Int(self.frame.width * UIScreen.main.scale * 2))&height=\(Int(self.frame.height * UIScreen.main.scale * 2))"
        let url = URL(string: paramUrlString)!
        let processor = DownsamplingImageProcessor(size: self.frame.size)
        self.kf.setImage(
            with: url,
            placeholder: placeHolderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale * 2),
                .transition(.fade(1)),
                .cacheOriginalImage
            ], completionHandler:
                {
                    result in
                    switch result {
                    case .success(_):
                        return
                    case .failure(let error):
                        print("Download image failure with error: \(error)")
                    }
                })
    }
}
