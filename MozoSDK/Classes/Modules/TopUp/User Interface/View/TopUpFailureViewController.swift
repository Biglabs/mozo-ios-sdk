//
//  TransferViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation
import UIKit
class TopUpFailureViewController: MozoBasicViewController {
    @IBOutlet weak var containerImageView: UIView!
    @IBOutlet weak var failedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fix issue: Title is not correct after navigation back from child controller
        navigationItem.title = "Deposit".localized
    }
    
    func updateLayout() {
        containerImageView.roundCorners(cornerRadius: 0.5, borderColor: .white, borderWidth: 0.1)
        let alert = UIImage(named: "ic_alert_fill", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        failedImageView.image = alert
        failedImageView.tintColor = .white
    }
}
