//
//  CustomImageView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 2/20/19.
//  Copyright © 2019 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class CustomImageView: UIImageView {
    var imageUrlString: String?
    
    func loadImageUsingUrlString(_ urlString: String, defaultImageName: String = "img_store_no_img", loadingColor: UIColor = ThemeManager.shared.main,
                                 isDefaultImageFromMozo: Bool = false, isShowLoading: Bool = false,
                                 isUseScreenCenter: Bool = false) {
        print("Download image with url: \(urlString)")
        if !defaultImageName.isEmpty {
            image = isDefaultImageFromMozo ? UIImage(named: defaultImageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
                : UIImage(named: defaultImageName)
        }
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
            print("Use saved cache image.")
            self.image = imageFromCache
            return
        }
        let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if isShowLoading {
            loadingView.color = loadingColor
            loadingView.frame = self.frame
            loadingView.center = self.center
            if isUseScreenCenter, let superview = self.superview {
                //                loadingView.frame = UIScreen.main.bounds
                loadingView.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: superview.bounds.height * 0.5)
            }
            loadingView.startAnimating()
            self.addSubview(loadingView)
        }
        DataRequest.addAcceptableImageContentTypes(["image/jpg"])
        Alamofire.request(urlString).responseImage { response in
            switch response.result {
            case .success( _):
                print("Download image success")
                DispatchQueue.main.async {
                    if let imageToCache = response.result.value {
                        print("Save cache image.")
                        if self.imageUrlString == urlString {
                            if isShowLoading {
                                loadingView.stopAnimating()
                                loadingView.removeFromSuperview()
                            }
                            self.image = imageToCache
                        }
                        imageCache.setObject(imageToCache, forKey: urlString as NSString)
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
