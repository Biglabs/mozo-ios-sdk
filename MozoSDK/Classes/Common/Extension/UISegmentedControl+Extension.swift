//
//  UISegmentedControl+Extension.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/6/19.
//

import Foundation
import UIKit
extension UISegmentedControl{
    func removeBorder(){
//        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: self.bounds.size)
//        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
//        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
//        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        
//        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(nil, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        
        self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(hexString: "333333"),
                                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], for: .normal)
        self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(hexString: "333333"),
                                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], for: .highlighted)
        self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(hexString: "4e94f3"),
                                     NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)], for: .selected)
    }
    
    func addUnderLines() {
        removeBorder()
        addUnderlineForSelectedSegment()
        addUnderlineForUnselectSegments()
    }
    
    func addUnderlineForSelectedSegment(){
        let underlineWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 4.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 4.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor(hexString: "4e94f3")
        underline.tag = 1
        self.addSubview(underline)
    }
    
    func addUnderlineForUnselectSegments() {
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
            underline.backgroundColor = UIColor(hexString: "98afcf")
            underline.tag = index
            index += 1
            self.addSubview(underline)
        }
    }
    
    func changeUnderlinePosition(){
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
