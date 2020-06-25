//
//  MozoWaitingView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/10/19.
//

import Foundation
public class MozoWaitingView: UIView {
    var containerView: UIView!
    
    var imgLoading: UIImageView!
    public var lbExplain: UILabel!
    
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    public var stopRotating = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func awakeFromNib() {
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
        let loading = UIImage(named: "ic_loading", in: BundleManager.mozoBundle(), compatibleWith: nil)
        imgLoading = UIImageView(frame: CGRect(x: 0, y: 153, width: 57, height: 54))
        imgLoading.image = loading
        imgLoading.translatesAutoresizingMaskIntoConstraints = false
//        imgLoading.center = CGPoint(x: center.x, y: 153 + 54 / 2)
        addSubview(imgLoading)
        
        lbExplain = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        lbExplain.numberOfLines = 10
        lbExplain.textAlignment = .center
        lbExplain.translatesAutoresizingMaskIntoConstraints = false
//        lbExplain.center = CGPoint(x: center.x, y: 223 + 10)
        addSubview(lbExplain)
        
        widthConstraint = NSLayoutConstraint(item: imgLoading, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 57)
        heightConstraint = NSLayoutConstraint(item: imgLoading, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 54)
        
        self.addConstraints([
            NSLayoutConstraint(item: imgLoading, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: imgLoading, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 217),
            widthConstraint,
            heightConstraint,
            NSLayoutConstraint(item: lbExplain, attribute: .centerX, relatedBy: .equal, toItem: imgLoading, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: lbExplain, attribute: .top, relatedBy: .equal, toItem: imgLoading, attribute: .bottom, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: lbExplain, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: -90)
            ])
        
        setupSpinningView()
    }
    
    func setupSpinningView() {
        let advTimeGif = UIImage.gifImageWithName("spinner")
        self.imgLoading.image = advTimeGif
    }
    
    public func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.imgLoading.transform = self.imgLoading.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if !self.stopRotating {
                self.rotateView(duration: duration)
            } else {
                self.imgLoading.transform = .identity
            }
        }
    }
    
    public func updateImageSize(_ size: CGSize) {
        let origin = imgLoading.frame.origin
        let newFrame = CGRect(origin: origin, size: size)
        imgLoading.frame = newFrame
        
        self.removeConstraints([widthConstraint, heightConstraint])
        widthConstraint = NSLayoutConstraint(item: imgLoading, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: size.width)
        heightConstraint = NSLayoutConstraint(item: imgLoading, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: size.height)
        
        self.addConstraints([widthConstraint, heightConstraint])
    }
}
