//
//  ChangePINProcessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINProcessViewController: MozoBasicViewController {
    var eventHandler: ChangePINModuleInterface?

    @IBOutlet weak var imgViewLoading: UIImageView!
    @IBOutlet weak var lbExplainWaiting: UILabel!
    
    var stopRotating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Change Security PIN".localized
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            stopRotating = true
        }
    }
    
    private func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.imgViewLoading.transform = self.imgViewLoading.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if !self.stopRotating {
                self.rotateView(duration: duration)
            } else {
                self.imgViewLoading.transform = .identity
            }
        }
    }
}
extension ChangePINProcessViewController: ChangePINProcessViewInterface {
    func displayError(_ error: String) {
        displayMozoError(error)
    }
}
