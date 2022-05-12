//
//  DemoViewController.swift
//  example
//
//  Created by Hoang Nguyen on 8/16/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import UIKit
import MozoSDK

class DemoViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "DEMO COMPONENTS"
//        MozoSDK.authenticate()
        MozoSDK.setAuthDelegate(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1200)
    }
}

extension DemoViewController: MozoAuthenticationDelegate {
	func didSignInSuccess() {
		let alert = UIAlertController(title: "MOZO", message: "Finish authentication", preferredStyle: .alert)
		alert.addAction(.init(title: "OK", style: .default))
		self.present(alert, animated: true, completion: nil)
	}
	
	func didLogoutSuccess() {
	}
	
	func mozoDidExpiredToken() {
		print("Mozo: Token Expired")
	}
	
	func mozoUIDidCloseAll() {
	}
}
