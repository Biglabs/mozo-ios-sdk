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
    @IBOutlet weak var autoImgCheck: UIImageView!
//    @IBOutlet weak var rocketImg: UIImageView!
    
    @IBOutlet weak var containerViewManual: UIView!
    @IBOutlet weak var manuImgCheck: UIImageView!
    
    @IBOutlet weak var lbExplainRecoveryPhrase: UILabel!
    
    @IBOutlet weak var footerContainerView: UIView!
    var containerViewAutoBorder: UIView!
    
    var isSelectAuto = true
    
    var barButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "title_create_wallet".localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButtonView)
    }
    
    override func viewDidLayoutSubviews() {
        print("SpeedSelectionViewController - View did layout subviews")
        super.viewDidLayoutSubviews()
    }
    
    func updateLayout() {
        containerViewAuto.roundCorners(cornerRadius: 0.015, borderColor: ThemeManager.shared.primary, borderWidth: 2.5)
        containerViewAuto.layer.cornerRadius = 6
        autoImgCheck.roundCorners(borderColor: UIColor.clear, borderWidth: 1)
        autoImgCheck.layer.cornerRadius = 12
        
        autoImgCheck.isHighlighted = true

        containerViewManual.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "cacaca"), borderWidth: 1)
        containerViewManual.layer.cornerRadius = 6
        manuImgCheck.roundCorners(borderColor: UIColor(hexString: "b9c1cc"), borderWidth: 1)
        manuImgCheck.layer.cornerRadius = 12
        
        if UIScreen.main.nativeBounds.height <= 1334.0 { // iPhone 4_4S_5_5s_5c_SE_6_6s_7_8
            lbExplainRecoveryPhrase.font = .systemFont(ofSize: 11)
        }
    }
    
    func highLightView(_ isAuto: Bool = true) {
        isSelectAuto = isAuto
        
        let highLightView = isAuto ? containerViewAuto : containerViewManual
        let notHighlightView = isAuto ? containerViewManual : containerViewAuto
        let highLightImage = isAuto ? autoImgCheck : manuImgCheck
        let notHighlightImage = isAuto ? manuImgCheck : autoImgCheck
        
        highLightView?.layer.borderWidth = 2.5
        highLightView?.layer.borderColor = ThemeManager.shared.primary.cgColor
        highLightImage?.layer.borderColor = UIColor.clear.cgColor
        
        notHighlightView?.layer.borderWidth = 1
        notHighlightView?.layer.borderColor = UIColor(hexString: "cacaca").cgColor
        notHighlightImage?.layer.borderColor = UIColor(hexString: "b9c1cc").cgColor
        
        highLightImage?.isHighlighted = true
        notHighlightImage?.isHighlighted = false
    }
    
    @IBAction func touchBtnAuto(_ sender: Any) {
        highLightView()
    }
    
    @IBAction func touchBtnManual(_ sender: Any) {
        highLightView(false)
    }
    
    @IBAction func touchBtnContinue(_ sender: Any) {
        if isSelectAuto {
            eventHandler?.decideAutoWay()
        } else {
            eventHandler?.decideManualWay()
        }
    }
    
    @IBAction func touchBtnLogout(_ sender: Any) {
        eventHandler?.requestLogout()
    }
}
