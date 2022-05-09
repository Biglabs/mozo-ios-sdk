//
//  WaitingViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/29/18.
//

import Foundation
enum WaitingRetryAction {
    case LoadUserProfile
    case BuildAuth
}
class WaitingViewController: MozoBasicViewController {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var eventHandler: CoreModuleWaitingInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
