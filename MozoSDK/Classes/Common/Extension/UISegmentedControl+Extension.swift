//
//  UISegmentedControl+Extension.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/6/19.
//

import Foundation
import UIKit
extension UISegmentedControl{
    func removeBorder(normalAttributes: [NSAttributedString.Key : Any], highlightedAttributes: [NSAttributedString.Key : Any], selectedAttributes: [NSAttributedString.Key : Any]){
//        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: self.bounds.size)
//        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
//        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
//        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        
//        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(nil, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        
        self.setTitleTextAttributes(normalAttributes, for: .normal)
        self.setTitleTextAttributes(highlightedAttributes, for: .highlighted)
        self.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    public func addUnderLines(normalAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: ThemeManager.shared.textSection,
                                                                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
                              highlightedAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: ThemeManager.shared.textSection,
                                                                                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
                              selectedAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "333333"),
                                                                                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)],
                              underLineColor: UIColor = ThemeManager.shared.primary,
                              underLineBorderColor: UIColor = UIColor(hexString: "f2f6fb"),
                              underLineBorderWidth: CGFloat = 1.0,
                              unselectUnderLineColor: UIColor = .white) {
        removeBorder(normalAttributes: normalAttributes, highlightedAttributes: highlightedAttributes, selectedAttributes: selectedAttributes)
        addUnderlineForSelectedSegment(underLineColor: underLineColor, underLineBorderColor: underLineBorderColor, underLineBorderWidth: underLineBorderWidth)
        addUnderlineForUnselectSegments(unselectUnderLineColor: unselectUnderLineColor)
    }
    
    func addUnderlineForSelectedSegment(underLineColor: UIColor, underLineBorderColor: UIColor, underLineBorderWidth: CGFloat){
        let underlineWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 4.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 4.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.roundCorners(cornerRadius: 0, borderColor: underLineBorderColor, borderWidth: underLineBorderWidth)
        underline.backgroundColor = underLineColor
        underline.tag = 1
        self.addSubview(underline)
    }
    
    func addUnderlineForUnselectSegments(unselectUnderLineColor: UIColor) {
        let underlineWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 2.0
        let underLineYPosition = self.bounds.size.height - 2.0
        var index = 2
        for i in 0..<numberOfSegments {
            if i == selectedSegmentIndex {
                continue
            }
            let underlineXPosition = CGFloat(i * Int(underlineWidth))
            let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
            let underline = UIView(frame: underlineFrame)
            underline.backgroundColor = unselectUnderLineColor
            underline.tag = index
            index += 1
            self.addSubview(underline)
        }
    }
    
    public func changeUnderlinePosition(){
        changeSelectedPosition()
        changeUnselectPositions()
    }
    
    func changeUnselectPositions() {
        var index = 2
        for i in 0..<numberOfSegments {
            if i == selectedSegmentIndex {
                continue
            }
            guard let underline = self.viewWithTag(index) else {return}
            let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(i)
            UIView.animate(withDuration: 0.1, animations: {
                underline.frame.origin.x = underlineFinalXPosition
            })
            index += 1
        }
    }
    
    func changeSelectedPosition() {
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
}
extension UIImage{
    
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}
