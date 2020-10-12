//
//  MozoView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/26/18.
//

import UIKit

@IBDesignable public class MozoView: UIView {
    @IBOutlet var containerView: UIView!
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    public override func awakeFromNib() {
        loadViewFromNib()
    }
    
    public override func layoutSubviews() {
        checkDisable()
    }
    
    func loadView(identifier: String) -> UIView {
        let bundle = BundleManager.mozoBundle()
        let view = bundle.loadNibNamed(identifier, owner: self, options: nil)?.first as! UIView
//
//        let bundle = BundleManager.mozoBundle()
//        let nib = UINib(nibName: identifier, bundle: bundle)
//        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        checkDisable()
        return view
    }

    func checkDisable() {
        
    }
    
    func updateView() {
        containerView.removeFromSuperview()
        loadViewFromNib()
        setNeedsLayout()
    }
    
    func loadViewFromNib() {
        let iden = identifier()
        if !iden.isEmpty {
            containerView = loadView(identifier: iden)
            addSubview(containerView)
        }
    }
    
    func identifier() -> String {
        return String(describing: self.classForCoder.self)
    }
    
    func updateOnlyBalance(_ balance : Double) {
    }
    
    // MARK: Observation Initialization
    func addUniqueAuthObserver() {
        #if !TARGET_INTERFACE_BUILDER
        NotificationCenter.default.removeObserver(self, name: .didAuthenticationSuccessWithMozo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didLogoutFromMozo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidLoginSuccess(_:)), name: .didAuthenticationSuccessWithMozo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidLogout(_:)), name: .didLogoutFromMozo, object: nil)
        #endif
    }
    
    func addOriginalObserver() {
        #if !TARGET_INTERFACE_BUILDER
        NotificationCenter.default.removeObserver(self, name: .didReceiveDetailDisplayItem, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveExchangeInfo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didLoadTokenInfoFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDetailDisplayDataDidReceive(_:)), name: .didReceiveDetailDisplayItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onExchangeRateInfoDidReceive(_:)), name: .didReceiveExchangeInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoadTokenInfoFailed(_:)), name: .didLoadTokenInfoFailed, object: nil)
        #endif
    }
    
    func addUniqueBalanceChangeObserver() {
        #if !TARGET_INTERFACE_BUILDER
        NotificationCenter.default.removeObserver(self, name: .didChangeBalance, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onBalanceDidUpdate(_:)), name: .didChangeBalance, object: nil)
        #endif
    }
    
    func removeObserverAfterLogout() {
        #if !TARGET_INTERFACE_BUILDER
        NotificationCenter.default.removeObserver(self, name: .didChangeBalance, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveDetailDisplayItem, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveExchangeInfo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didLoadTokenInfoFailed, object: nil)
        #endif
    }
    
    // MARK: Observation actions
    @objc func onUserDidLoginSuccess(_ notification: Notification) {
        print("On User Did Login Success: Update view")
        updateView()
    }
    
    @objc func onUserDidLogout(_ notification: Notification) {
        print("On User Did Logout: Update view")
        removeObserverAfterLogout()
        updateView()
    }
    
    @objc func onBalanceDidUpdate(_ notification: Notification){
        print("On Balance Did Update: Update only balance")
        if let data = notification.userInfo as? [String : Any?] {
            let balance = data["balance"] as! Double
            updateOnlyBalance(balance)
        }
    }
    
    @objc func onDetailDisplayDataDidReceive(_ notification: Notification){
        print("On Detail Display Data Did Receive: Update view")
        updateView()
    }
    
    @objc func onLoadTokenInfoFailed(_ notification: Notification){
        print("On Load Token Info Failed: Update view")
        
    }
    
    @objc func onExchangeRateInfoDidReceive(_ notification: Notification){
        print("On Exchange Rate Info Did Receive: Update view")
        updateView()
    }
    
    // MARK: Observation - REVOKE
    func removeAllMozoObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Dealloccation
    deinit {
        // TODO: Remove observation
        removeAllMozoObserver()
    }
}
