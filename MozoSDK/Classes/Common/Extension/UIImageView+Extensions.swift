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

let imageCache = NSCache<NSString, AnyObject>()
public extension UIImageView {
    public func loadImageWithUrlString(_ urlString: String, defaultImageName: String = "img_store_no_img", loadingColor: UIColor = ThemeManager.shared.main,
                                isDefaultImageFromMozo: Bool = false, isShowLoading: Bool = false,
                                isUseScreenCenter: Bool = false) {
        print("Download image with url: \(urlString)")
        let paramUrlString = "\(urlString)?width=\(Int(self.frame.width * UIScreen.main.scale * 2))&height=\(Int(self.frame.height * UIScreen.main.scale * 2))"
        print("Download image with url param: \(paramUrlString)")
        if !defaultImageName.isEmpty {
            image = isDefaultImageFromMozo ? UIImage(named: defaultImageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
                : UIImage(named: defaultImageName)
        }
        
        if let imageFromCache = imageCache.object(forKey: paramUrlString as NSString) as? UIImage {
            print("Use saved cache image.")
            self.image = imageFromCache
            return
        }
        let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if isShowLoading {
            loadingView.color = loadingColor
            loadingView.frame = self.frame
            loadingView.center = self.center
            if isUseScreenCenter {
//                loadingView.frame = UIScreen.main.bounds
                loadingView.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.5)
            }
            loadingView.startAnimating()
            self.addSubview(loadingView)
        }
        DataRequest.addAcceptableImageContentTypes(["image/jpg"])
        Alamofire.request(paramUrlString).responseImage { response in
            switch response.result {
            case .success( _):
                print("Download image success")
                DispatchQueue.main.async {
                    if let imageToCache = response.result.value {
                        print("Save cache image.")
                        
                        if isShowLoading {
                            loadingView.stopAnimating()
                            loadingView.removeFromSuperview()
                        }
                        self.image = imageToCache
                        
                        imageCache.setObject(imageToCache, forKey: paramUrlString as NSString)
                    } else {
                        print("Unable to init UIImage from data.")
                    }
                }
            case .failure(let error):
                print("Download image failure with error: \(error)")
            }
        }
    }
}
