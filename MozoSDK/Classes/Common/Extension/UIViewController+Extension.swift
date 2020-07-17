//
//  UIViewController+Extension.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/16/19.
//

import Foundation
import SafariServices
public extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func openLink(link : String) {
        if var url = URL(string: link) {
            url.appendQueryItem(name: "language", value: Configuration.LOCALE)
            present(SFSafariViewController(url: url), animated: true, completion: nil)
        }
    }
}
