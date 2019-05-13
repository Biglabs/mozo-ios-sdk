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
    var eventHandler: CoreModuleWaitingInterface?
    @IBOutlet weak var imgLoading: UIImageView!
    
    var stopRotating = false
    // TODO: Rotate never stop
    
    var retryAction: WaitingRetryAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotateView()
    }
    
    private func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.imgLoading.transform = self.imgLoading.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if !self.stopRotating {
                self.rotateView(duration: duration)
            } else {
                self.imgLoading.transform = .identity
            }
        }
    }
}
extension WaitingViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        
    }
    
    func didTouchTryAgainButton() {
        if let retryAction = self.retryAction {
            print("User try reload user profile on waiting screen again.")
            switch retryAction {
            case .LoadUserProfile:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
                    self.eventHandler?.retryGetUserProfile()
                }
                break
            case .BuildAuth:
                self.eventHandler?.retryAuth()
                break
            }
            
        }
    }
}
extension WaitingViewController: WaitingViewInterface {
    func displayTryAgain(_ error: ConnectionError, forAction: WaitingRetryAction?) {
        self.retryAction = forAction
        if error == .apiError_INVALID_USER_TOKEN {
            displayMozoPopupTokenExpired()
        } else {
            DisplayUtils.displayTryAgainPopup(error: error, delegate: self)
        }
    }
}
