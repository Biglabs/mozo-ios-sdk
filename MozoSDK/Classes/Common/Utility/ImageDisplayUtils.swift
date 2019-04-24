//
//  ImageDisplayUtils.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/22/19.
//

import Foundation
public class ImageDisplayUtils {
    public static func displayExpandImageView(names: [String], selectedIndex: Int = 0) {
        if let parentView = UIApplication.shared.keyWindow {
            let screenWidth = parentView.bounds.width
            let screenHeight = parentView.bounds.height
            
            var topPadding : CGFloat = 0.0
            var bottomPadding : CGFloat = 0.0
            if #available(iOS 11.0, *) {
                topPadding = parentView.safeAreaInsets.top
                bottomPadding = parentView.safeAreaInsets.bottom
            }
            
            let displayWidth: CGFloat = screenWidth
            let displayHeight: CGFloat = screenHeight + topPadding + bottomPadding
            let viewFrame = CGRect(x: 0, y: 0 - topPadding, width: displayWidth, height: displayHeight)
            
            let view = ExpandImageView(frame: viewFrame)
            view.names = names
            view.selectedIndex = selectedIndex
            
            parentView.addSubview(view)
        }
    }
    
    public static func reArrangeStringArray(strings: [String], index: Int) -> [String]{
        if index == 0 {
            return strings
        }
        let range = strings[index...]
        var result : [String] = Array(range)
        result.append(contentsOf: Array(strings[..<index]))
        return result
    }
}
