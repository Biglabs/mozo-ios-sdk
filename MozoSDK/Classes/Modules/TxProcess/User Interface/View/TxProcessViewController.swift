//
//  TxProcessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
class TxProcessViewController: MozoBasicViewController {
    @IBOutlet weak var imgLoading: UIImageView!
    @IBOutlet weak var lbStepTitle: UILabel!
    @IBOutlet weak var lbStepDes: UILabel!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var lbHide: UILabel!
    
    var eventHandler: TxProcessModuleInterface?
    var currentStep = TxProcessStep.Broadcasting
    
    var stopLoading = false
    
<<<<<<< HEAD
    var moduleRequest = Module.Convert
    
=======
>>>>>>> SDK_Version_1.3
    override func viewDidLoad() {
        super.viewDidLoad()
        lbStepTitle.text = currentStep.title
        updateLayout()
        prepareNextSteps()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
<<<<<<< HEAD
        if moduleRequest == .Convert {
            self.title = "Convert To Offchain".localized
        }
        navigationItem.rightBarButtonItem = nil
=======
        navigationController?.isNavigationBarHidden = true
>>>>>>> SDK_Version_1.3
    }
    
    func updateLayout() {
        rotateView()
        btnHide.roundCorners(cornerRadius: 0.15, borderColor: UIColor(hexString: "4e94f3"), borderWidth: 1.1)
        btnHide.layer.cornerRadius = 22.5
    }
    
    private func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.imgLoading.transform = self.imgLoading.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if !self.stopLoading {
                self.rotateView(duration: duration)
            } else {
                self.imgLoading.transform = .identity
            }
        }
    }
    
    func prepareNextSteps() {
        if currentStep.rawValue < TxProcessStep.Waiting.rawValue {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(currentStep.delaySeconds)) {
                self.currentStep = TxProcessStep(rawValue: self.currentStep.rawValue + 1)!
                self.lbStepTitle.text = self.currentStep.title
                self.prepareNextSteps()
            }
        }
    }
    
    func handleHideAction() {
        if let navigationController = self.navigationController as? MozoNavigationController, let coreEventHandler = navigationController.coreEventHandler {
            eventHandler?.hideProcess()
            coreEventHandler.requestForCloseAllMozoUIs()
        }
    }
    
    @IBAction func touchBtnHide(_ sender: Any) {
<<<<<<< HEAD
        handleHideAction()
=======
        eventHandler?.hideProcess()
>>>>>>> SDK_Version_1.3
    }
}
