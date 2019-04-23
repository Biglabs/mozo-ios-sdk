//
//  ExpandImageView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/22/19.
//

import Foundation

class ExpandImageView: UIView {
    var containerView: UIView!
    @IBOutlet weak var mainImgView: UIImageView!
    @IBOutlet weak var imgCloseView: UIImageView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadViewFromNib()
    }
    
    var url : String? {
        didSet {
            if let url = url {
                self.mainImgView.loadImageWithUrlString(url, defaultImageName: "", isShowLoading: true, isUseScreenCenter: true)
            }
        }
    }
    
    func loadView(identifier: String) -> UIView {
        let bundle = BundleManager.mozoBundle()
        let nib = UINib(nibName: identifier, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return view
    }
    
    func loadViewFromNib() {
        let iden = "ExpandImageView"
        if !iden.isEmpty {
            containerView = loadView(identifier: iden)
            addSubview(containerView)
            updateImageLayout()
        }
    }
    
    func updateImageLayout() {
        let imgClose = UIImage(named: "ic_close", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgCloseView.image = imgClose
        imgCloseView.tintColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchClose))
        tap.numberOfTapsRequired = 1
        imgCloseView.isUserInteractionEnabled = true
        imgCloseView.addGestureRecognizer(tap)
    }
    
    @objc func touchClose() {
        containerView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
