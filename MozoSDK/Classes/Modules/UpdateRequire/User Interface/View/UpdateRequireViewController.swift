//
//  UpdateRequireViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/16/20.
//

import Foundation
class UpdateRequireViewController: UIViewController {
    @IBOutlet weak var updateImageView: UIImageView!
    @IBOutlet weak var updateImageViewTopConstraint: NSLayoutConstraint! // Default 138
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    func setupLayout() {
        let bundle = BundleManager.mozoBundle()
        let image = UIImage(named: "img_update_require", in: bundle, compatibleWith: nil)
        updateImageView.image = image
        
        btnUpdate.roundCorners(borderColor: .white, borderWidth: 0.1)
        btnUpdate.layer.cornerRadius = 5
        
        lbDesc.text = "We’ve released a new version of the app\nPlease update the latest version.".localized
        
        // Update layout for iPhone 5 below
        if UIScreen.main.nativeBounds.height <= 1136 {
            updateImageViewTopConstraint.constant = 20
        }
    }
        
    @IBAction func touchBtnUpdate(_ sender: Any) {
        openLink(link: DisplayUtils.appType.appStoreUrl)
    }
}
extension UpdateRequireViewController {
    public static func viewControllerFromXIB() -> UpdateRequireViewController {
        let bundle = BundleManager.mozoBundle()
        let viewController = UpdateRequireViewController(nibName: String(describing: UpdateRequireViewController.self), bundle: bundle)
        return viewController
    }
}
