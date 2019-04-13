//
//  MozoPopupErrorView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/11/18.
//

import Foundation
import Reachability
public protocol PopupErrorDelegate {
    func didTouchTryAgainButton()
    func didClosePopupWithoutRetry()
}

class MozoPopupErrorView : MozoView {
    @IBOutlet weak var imgError: UIImageView!
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var btnTry: UIButton!
    
    var modalCloseHandler: (() -> Void)?
    var tapTryHandler: (() -> Void)?
    
    var error : ConnectionError = ConnectionError.apiError_INTERNAL_ERROR { //System Error
        didSet {
            setImageAndLabel()
        }
    }
    var delegate: PopupErrorDelegate?
    
    var reachability : Reachability?
    
    override init(frame: CGRect) {
        print("MozoPopupErrorView - Init with frame")
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("MozoPopupErrorView - Init with coder")
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        setupReachability()
    }
    
    // MARK: Reachability
    func setupReachability() {
        let hostName = Configuration.BASE_HOST
        print("MozoPopupErrorView - Set up Reachability with host name: \(hostName)")
        reachability = Reachability(hostname: hostName)
        reachability?.whenReachable = { reachability in
            print("MozoPopupErrorView - Reachability when reachable: \(reachability.description) - \(reachability.connection)")
            self.stopNotifier()
            self.tryAgain()
        }
        reachability?.whenUnreachable = { reachability in
            print("MozoPopupErrorView - Reachability when unreachable: \(reachability.description) - \(reachability.connection)")
            
        }
        print("MozoPopupErrorView - Reachability --- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            
        }
    }
    
    func stopNotifier() {
        print("MozoPopupErrorView - Reachability --- stop notifier")
        reachability?.stopNotifier()
        reachability = nil
    }
    
    deinit {
        stopNotifier()
    }
    
    override func identifier() -> String {
        return "MozoPopupErrorView"
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        setImageAndLabel()
        setupBorder()
    }
    
    func setupBorder() {
        btnTry.roundCorners(cornerRadius: 0.15, borderColor: .white, borderWidth: 0.1)
    }
    
    func setImageAndLabel() {
        if error.isApiError {
            labelError.text = (error.apiError?.description ?? "System Error").localized
        } else {
            if error == .requestTimedOut {
                imgError.image = UIImage(named: "ic_sand_clock", in: BundleManager.mozoBundle(), compatibleWith: nil)
                labelError.text = "Time out, please try again.".localized
            } else {
                imgError.image = UIImage(named: "ic_no_connection", in: BundleManager.mozoBundle(), compatibleWith: nil)
                labelError.text = "There is no internet connection!".localized
            }
        }
    }
    
    @objc
    public func dismissView() {
        modalCloseHandler?()
        delegate?.didClosePopupWithoutRetry()
    }
    
    func tryAgain() {
        delegate?.didTouchTryAgainButton()
        tapTryHandler?()
    }
    
    @IBAction func touchedTryBtn(_ sender: Any) {
        tryAgain()
    }
}
