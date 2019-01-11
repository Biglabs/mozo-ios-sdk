//
//  MozoPopupErrorView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/11/18.
//

import Foundation
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
    
    override func identifier() -> String {
        return "MozoPopupErrorView"
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        setImageAndLabel()
    }
    
    func setImageAndLabel() {
        if error.isApiError {
            labelError.text = error.apiError?.description ?? "System Error"
        } else {
            imgError.image = UIImage(named: "ic_no_connection", in: BundleManager.mozoBundle(), compatibleWith: nil)
            labelError.text = "There is no internet connection!"
        }
    }
    
    @objc
    public func dismissView() {
        modalCloseHandler?()
        delegate?.didClosePopupWithoutRetry()
    }
    
    @IBAction func touchedTryBtn(_ sender: Any) {
        delegate?.didTouchTryAgainButton()
        tapTryHandler?()
    }
}
