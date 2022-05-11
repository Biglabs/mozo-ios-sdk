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

public extension UIImageView {
    func load(
        _ url: String?,
        placeHolder: String = "ic_store_profile",
        shouldScale: Bool = true,
        transforms: [SDImageTransformer]? = nil,
        _ onLoadComplete: (() -> Void)? = nil
    ) {
        let placeHolderImage = UIImage(named: placeHolder) ?? placeHolder.asMozoImage()?.withRenderingMode(.alwaysOriginal)
        
        guard let safeUrl = url?.trim(), !safeUrl.isEmpty else {
            self.image = placeHolderImage
            onLoadComplete?()
            return
        }

        let scale = UIScreen.main.scale
        let scaledW = Int(self.frame.width * scale)
        let scaledH = Int(self.frame.height * scale)
        
        var finalUrl = safeUrl
        if safeUrl == "dummy" {
            let color = Int.random(in: 2000..<10000)
            finalUrl = "https://dummyimage.com/\(scaledW)x\(scaledH)/\(color)/f\(color / 2)"
            
        } else if !safeUrl.hasPrefix("http") {
            finalUrl = "\(Configuration.DOMAIN_IMAGE)\(safeUrl)"
            
            if shouldScale {
                finalUrl = "\(finalUrl)?width=\(scaledW)&height=\(scaledH)"
            }
        }

//        let thumbnailSize = CGSize(width: 200 * scale, height: 200 * scale)
        var pipeline = SDImagePipelineTransformer(
            transformers: [
//                thumbnailSize
            ]
        )
        if var trans = transforms {
            trans.append(contentsOf: pipeline.transformers)
            pipeline = SDImagePipelineTransformer(
                transformers: trans
            )
        }
        
        self.sd_imageTransition = .fade
        self.sd_setImage(
            with: URL(string: finalUrl),
            placeholderImage: placeHolderImage,
            options: [
                .progressiveLoad, .retryFailed
            ],
            context: [
                .imageTransformer: pipeline
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
