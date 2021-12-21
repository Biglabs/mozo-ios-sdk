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
    func load(
        _ url: String?,
        placeHolder: String = "ic_store_profile",
        _ onLoadComplete: (() -> Void)? = nil
    ) {
        let placeHolderImage = UIImage(named: placeHolder) ?? placeHolder.asMozoImage()?.withRenderingMode(.alwaysOriginal)
        
        guard let safeUrl = url?.trimmingCharacters(in: .whitespacesAndNewlines), !safeUrl.isEmpty else {
            self.image = placeHolderImage
            onLoadComplete?()
            return
        }

        let scale = UIScreen.main.scale
        let iWidth = Int(self.frame.width * scale)
        let iHeight = Int(self.frame.height * scale)
        
        var finalUrl = safeUrl
        if !safeUrl.hasPrefix("http") {
            finalUrl = "\(Configuration.DOMAIN_IMAGE)\(safeUrl)?width=\(iWidth)&height=\(iHeight)"
        }
    
        self.sd_imageTransition = .fade
        self.sd_setImage(
            with: URL(string: finalUrl),
            placeholderImage: placeHolderImage,
            options: [],
            context: [
                .imageThumbnailPixelSize : CGSize(width: iWidth, height: iHeight),
                .imageScaleFactor: 0.2
            ],
            progress: nil,
            completed: { _, error, _, loadedUrl in
                onLoadComplete?()
                if error != nil {
                    "🔴 \(loadedUrl?.absoluteString ?? "")\n\(error?.localizedDescription ?? "")".log()
                }
            }
        )
    }
}
