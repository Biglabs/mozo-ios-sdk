//
//  MozoWaitingView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/10/19.
//

import Foundation
public class MozoWaitingView: UIView {
    var containerView: UIView!
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
        let loadingSize = CGRect(x: 0, y: 153, width: 64, height: 64)
        let imgLoading = UIActivityIndicatorView(frame: loadingSize)
        imgLoading.startAnimating()
        imgLoading.color = ThemeManager.shared.primary
        imgLoading.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imgLoading)
        
        lbExplain = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        lbExplain.numberOfLines = 10
        lbExplain.textAlignment = .center
        lbExplain.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lbExplain)
        
        widthConstraint = NSLayoutConstraint(
            item: imgLoading, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: loadingSize.width)
        heightConstraint = NSLayoutConstraint(
            item: imgLoading, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: loadingSize.height)
        
        self.addConstraints([
            NSLayoutConstraint(item: imgLoading, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: imgLoading, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 217),
            widthConstraint,
            heightConstraint,
            NSLayoutConstraint(item: lbExplain!, attribute: .centerX, relatedBy: .equal, toItem: imgLoading, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: lbExplain!, attribute: .top, relatedBy: .equal, toItem: imgLoading, attribute: .bottom, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: lbExplain!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: -90)
            ])
    }
}
