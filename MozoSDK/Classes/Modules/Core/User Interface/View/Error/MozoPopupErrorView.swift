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

public class MozoPopupErrorView : MozoView {
    @IBOutlet weak var imgError: UIImageView!
    @IBOutlet weak var imgErrorWidthConstraint: NSLayoutConstraint! // Default: 102
    @IBOutlet weak var imgErrorHeightConstraint: NSLayoutConstraint! // Default: 102
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var lbDescHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnTry: UIButton!
    
    var modalCloseHandler: (() -> Void)?
    var tapTryHandler: (() -> Void)?
    
    var shouldTrackNetwork = false
    var isEmbedded = false
    
    let defaultImgErrorSize = CGSize(width: 102, height: 102)
    let networkImgErrorSize = CGSize(width: 95, height: 67)
    
    var error : ConnectionError = ConnectionError.apiError_INTERNAL_ERROR { //System Error
        didSet {
            commonInit()
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
        if error == .noInternetConnection, reachability == nil, shouldTrackNetwork {
            setupReachability()
        }
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
    
    public func forceDisable() {
        print("MozoPopupErrorView - Force disable")
        stopNotifier()
    }
    
    func stopNotifier() {
        print("MozoPopupErrorView - Reachability --- stop notifier")
        reachability?.stopNotifier()
        reachability = nil
    }
    
    deinit {
        if error == .noInternetConnection {
            stopNotifier()
        }
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
        imgErrorWidthConstraint.constant = defaultImgErrorSize.width
        imgErrorHeightConstraint.constant = defaultImgErrorSize.height
        if error.isApiError {
            labelError.text = "There is an error occurred.".localized
            lbDesc.text = (error.apiError?.description ?? "System Error").localized
        } else {
            if error == .requestTimedOut {
                imgError.image = UIImage(named: "ic_sand_clock", in: BundleManager.mozoBundle(), compatibleWith: nil)
                labelError.text = "Time out, please try again.".localized
                lbDesc.text = ""
                lbDescHeightConstraint.constant = 0
            } else {
                imgError.image = UIImage(named: "ic_no_connection", in: BundleManager.mozoBundle(), compatibleWith: nil)
                labelError.text = "No Internet Connection".localized
                lbDesc.text = "Once you have a stronger internet connection, we’ll automatically process your request.".localized
                lbDescHeightConstraint.constant = 72.0
                imgErrorWidthConstraint.constant = networkImgErrorSize.width
                imgErrorHeightConstraint.constant = networkImgErrorSize.height
            }
        }
        if isEmbedded {
            lbDesc.text = ""
            lbDescHeightConstraint.constant = 0.0
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
