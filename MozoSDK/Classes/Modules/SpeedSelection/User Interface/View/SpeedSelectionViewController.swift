//
//  SpeedSelectionViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation

class SpeedSelectionViewController : MozoBasicViewController {
    var eventHandler: SpeedSelectionModuleInterface?
    
    @IBOutlet weak var containerViewAuto: UIView!
    @IBOutlet weak var rocketImg: UIImageView!
    
    @IBOutlet weak var containerViewManual: UIView!
    
    var containerViewAutoBorder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Create MozoX Wallet".localized
    }
    
    override func viewDidLayoutSubviews() {
        print("SpeedSelectionViewController - View did layout subviews")
        super.viewDidLayoutSubviews()
        
//        let rectShadow = CGRect(x: 0, y: 0, width: containerViewAutoBorder.bounds.width, height: containerViewAutoBorder.bounds.height)
//        print("Rect shadow: \(rectShadow)")
//        containerViewAutoBorder.layer.shadowPath = UIBezierPath(rect: rectShadow).cgPath
    }
    
    func updateLayout() {
        containerViewAuto.roundCorners(cornerRadius: 0.015, borderColor: .clear, borderWidth: 0.1)
        containerViewAuto.layer.cornerRadius = 6
        
//        containerViewAutoBorder = UIView(frame: CGRect(x: containerViewAuto.frame.origin.x, y: containerViewAuto.frame.origin.y, width: containerViewAuto.frame.width + 16, height: containerViewAuto.frame.height + 16))
//        containerViewAutoBorder.backgroundColor = .clear
//        view.insertSubview(containerViewAutoBorder, belowSubview: containerViewAuto)
//
//        containerViewAutoBorder.dropShadow()
//        containerViewAutoBorder.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
//        containerViewAutoBorder.layer.shadowRadius = 3.0
//        containerViewAutoBorder.layer.shadowColor = UIColor(hexString: "006dff").cgColor
//
//        containerViewAutoBorder.translatesAutoresizingMaskIntoConstraints = false
//
//        self.view.addConstraints([
//            NSLayoutConstraint(item: containerViewAutoBorder, attribute: .centerX, relatedBy: .equal, toItem: self.containerViewAuto, attribute: .centerX, multiplier: 1.0, constant: 0),
//            NSLayoutConstraint(item: containerViewAutoBorder, attribute: .top, relatedBy: .equal, toItem: self.containerViewAuto, attribute: .top, multiplier: 1.0, constant: 0.0),
//            NSLayoutConstraint(item: containerViewAutoBorder, attribute: .width, relatedBy: .equal, toItem: self.containerViewAuto, attribute: .width, multiplier: 1.0,  constant: 16),
//            NSLayoutConstraint(item: containerViewAutoBorder, attribute: .height, relatedBy: .equal, toItem: self.containerViewAuto, attribute: .height, multiplier: 1.0, constant: 8)
//            ])
//
        containerViewManual.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "cacaca"), borderWidth: 1)
        containerViewManual.layer.cornerRadius = 6
    }
    
    @IBAction func touchBtnAuto(_ sender: Any) {
        eventHandler?.decideAutoWay()
    }
    
    @IBAction func touchBtnManual(_ sender: Any) {
        eventHandler?.decideManualWay()
    }
}
