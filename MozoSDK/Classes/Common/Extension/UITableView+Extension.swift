//
//  UITableView+Extension.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/25/19.
//

import Foundation
public extension UITableView {
    func applyFooterLoadingView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: superview!.frame.width, height: 50))
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.startAnimating()
        ai.center = footerView.center
        footerView.addSubview(ai)
        tableFooterView = footerView
        tableFooterView?.isHidden = true
    }
}
