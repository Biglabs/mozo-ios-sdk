//
//  GradientView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/26/19.
//

import Foundation
@IBDesignable
final class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor(hexString: "33000000")
    @IBInspectable var endColor: UIColor = UIColor(hexString: "00000000")
    
    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: frame.size.width,
                                height: frame.size.height)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.zPosition = -1
        layer.addSublayer(gradient)
    }
}
