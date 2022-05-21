//
//  MozoPopupErrorView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/11/18.
//

import Foundation
import Alamofire

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
    
    var error : ConnectionError = ConnectionError.apiError_INTERNAL_ERROR
    var delegate: PopupErrorDelegate?
    
    private var networkManager: NetworkReachabilityManager?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.commonInit()
        self.setImageAndLabel()
    }
    
    private func commonInit() {
        if shouldTrackNetwork {
            if error != .noInternetConnection {
                error = .noInternetConnection
            }
            
            if !ModuleDependencies.shared.corePresenter.isNetworkAvailable {
                networkManager = NetworkReachabilityManager()!
                networkManager?.stopListening()
                networkManager?.startListening(onQueue: DispatchQueue.main) { (status) in
                    switch(status) {
                    case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                        self.stopNotifier()
                        self.tryAgain()
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    public func forceDisable() {
        stopNotifier()
    }
    
    func stopNotifier() {
        networkManager?.stopListening()
        networkManager = nil
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
