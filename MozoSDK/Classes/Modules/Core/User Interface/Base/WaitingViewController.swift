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
    case PerformSignIn
    case PerformSignOut
}
internal class WaitingViewController: MozoBasicViewController {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    private static var instance: WaitingViewController? = nil
    var autoPin: Bool = false
    var isCreateMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WaitingViewController.instance = self
        self.loadingIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        if autoPin {
            let msg = isCreateMode ? "text_explain_creating_wallet" : "text_explain_recovering_wallet"
            messageLabel.text = msg.localized
        } else {
            messageLabel.text = "Loading...".localized
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WaitingViewController.instance = nil
    }
    
    class func dismiss() {
        WaitingViewController.instance?.dismiss(animated: false)
        WaitingViewController.instance = nil
    }
}
