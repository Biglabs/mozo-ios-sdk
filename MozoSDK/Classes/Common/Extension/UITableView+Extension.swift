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
        let ai = UIActivityIndicatorView(style: .gray)
        ai.startAnimating()
        ai.center = footerView.center
        footerView.addSubview(ai)
        tableFooterView = footerView
        tableFooterView?.isHidden = true
    }
    
    func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }

    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                     let indexPath = IndexPath(row: 0, section: 0)
                     self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }

    enum scrollsTo {
        case top,bottom
    }
}
