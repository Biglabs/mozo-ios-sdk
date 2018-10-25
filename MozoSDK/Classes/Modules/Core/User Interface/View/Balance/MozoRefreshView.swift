//
//  MozoRefreshView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/24/18.
//

import Foundation
class MozoRefreshView: UIView {
    var containerView: UIView!
    @IBOutlet weak var btnRefresh: UIButton!
    var isRefreshing : Bool = false {
        didSet {
            ai.isHidden = !isRefreshing
            if btnRefresh != nil {
                btnRefresh.isHidden = isRefreshing
            }
        }
    }
    let ai = UIActivityIndicatorView(activityIndicatorStyle: .white)

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    func loadViewFromNib(){
        let nib = UINib(nibName: "MozoRefreshView", bundle: BundleManager.mozoBundle())
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = frame
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.backgroundColor = UIColor(white: 1, alpha: 0.75)
        containerView = view
        addSubview(containerView)
//        setupAI()
    }
    
    func setupAI() {
        ai.color = ThemeManager.shared.main
        // make the area larger
        ai.frame = self.frame
        ai.center = self.center
        // set a background color
        ai.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.35).cgColor
        ai.isHidden = true
    }
    
    @IBAction func touchedRefreshBtn(_ sender: Any) {
        isRefreshing = true
        _ = MozoSDK.loadBalanceInfo()
    }
}
