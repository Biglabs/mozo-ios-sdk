//
//  UIImageView+Extensions.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let imageCache = NSCache<NSString, AnyObject>()
public extension UIImageView {
    func load(_ url: String?) {
        let placeHolder = UIImage(named: "ic_store_profile", in: BundleManager.mozoBundle(), compatibleWith: nil)
        if let safeUrl = url, !safeUrl.isEmpty {
            var finalUrl = safeUrl
            if !safeUrl.starts(with: "http") {
                finalUrl = "\(Configuration.DOMAIN_IMAGE)\(safeUrl)?width=\(Int(self.frame.width * UIScreen.main.scale * 2))&height=\(Int(self.frame.height * UIScreen.main.scale * 2))"
            }
            
            let scale = UIScreen.main.scale // Will be 2.0 on 6/7/8 and 3.0 on 6+/7+/8+ or later
            let thumbnailSize = CGSize(width: 200 * scale, height: 200 * scale) // Thumbnail will bounds to (200,200) points
            self.sd_imageTransition = .fade
            self.sd_setImage(
                with: URL(string: finalUrl),
                placeholderImage: placeHolder,
                options: [],
                context: [
                    .imageThumbnailPixelSize : thumbnailSize,
                    .imageScaleFactor: 0.8
                ],
                progress: nil,
                completed: { _, error, _, loadedUrl in
                    if error != nil {
                        "🔴 \(loadedUrl?.absoluteString ?? "")\n\(error?.localizedDescription ?? "")".log()
                    }
                }
            )
        } else {
            image = placeHolder
        }
    }
    
    func loadImage(
        _ urlString: String,
        defaultImageName: String = "img_store_no_img",
        isDefaultImageFromMozo: Bool = false,
        _ onLoadComplete: (() -> Void)? = nil
    ) {
        let placeHolderImage = isDefaultImageFromMozo ? UIImage(named: defaultImageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
            : UIImage(named: defaultImageName)
        let paramUrlString = "\(urlString)?width=\(Int(self.frame.width * UIScreen.main.scale * 2))&height=\(Int(self.frame.height * UIScreen.main.scale * 2))"
        
        let scale = UIScreen.main.scale // Will be 2.0 on 6/7/8 and 3.0 on 6+/7+/8+ or later
        let thumbnailSize = CGSize(width: 200 * scale, height: 200 * scale) // Thumbnail will bounds to (200,200) points
        self.sd_imageTransition = .fade
        self.sd_setImage(
            with: URL(string: paramUrlString),
            placeholderImage: placeHolderImage,
            options: [],
            context: [
                .imageThumbnailPixelSize : thumbnailSize,
                .imageScaleFactor: 0.8
            ],
            progress: nil,
            completed: { _, error, _, loadedUrl in
                onLoadComplete?()
                if error != nil {
                    "🔴 \(loadedUrl?.absoluteString ?? "")\n\(error?.localizedDescription ?? "")".log()
                }
            })
    }
}
