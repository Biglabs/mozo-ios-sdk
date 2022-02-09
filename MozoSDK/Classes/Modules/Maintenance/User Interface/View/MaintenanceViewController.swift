//
//  MaintenanceViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
import UIKit
let MaintenanceViewControllerIdentifier = "MaintenanceViewController"
class MaintenanceViewController: UIViewController {
    let eventHandler = MaintenancePresenter()
    @IBOutlet weak var imgViewMaintenanceTopConstraint: NSLayoutConstraint! // Default 64
    @IBOutlet weak var imgViewMaintenance: UIImageView!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint! // Default 48
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgQuestion: UIImageView!
    @IBOutlet weak var lbQuestionTitle: UILabel!
    @IBOutlet weak var txAnswer: UITextView!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var imgArrow: UIImageView!
    
    let displayData = FAQDisplayData()
    var displayItem: FAQDisplayItem!
    
    override func viewDidLoad() {
        print("MaintenanceViewController - View did load")
        super.viewDidLoad()
        eventHandler.viewInterface = self
        eventHandler.startWaiting()
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: containerView.layer.cornerRadius
        ).cgPath
    }
    
    func setupLayout() {
        containerView.dropShadow()
        
        let iArrow = UIImage(named: "ic_left_arrow_white", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgArrow.image = iArrow
        imgArrow.tintColor = ThemeManager.shared.primary
        imgArrow.transform = imgArrow.transform.rotated(by: CGFloat.pi)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openReadMore))
        tap.numberOfTapsRequired = 1
        imgArrow.isUserInteractionEnabled = true
        imgArrow.addGestureRecognizer(tap)
        
        if UIScreen.main.nativeBounds.height <= 1334 {
            imgViewMaintenanceTopConstraint.constant = 64 / 2
            containerViewTopConstraint.constant = 48 / 2
        }
        
        displayItem = displayData.randomItem()
        lbQuestionTitle.text = displayItem.title.localized
        
        let displayText = displayItem.answer.localized
        txAnswer.attributedText = displayText.convertHtmlToAttributedStringWithCSS(font: UIFont.systemFont(ofSize: 16), csscolor: "black", lineheight: 5, csstextalign: "unset")
        
//        let lbWidth = UIScreen.main.bounds.width
//        let fontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
//        let size = displayText.size(withAttributes: fontAttributes)
        
        print("Label title, minY [\(lbQuestionTitle.frame.minY)], maxY [\(lbQuestionTitle.frame.maxY)]")
        
        print("Label answer, minY [\(txAnswer.frame.minY)], maxY [\(txAnswer.frame.maxY)]")
        
        print("Button read more, minY [\(btnReadMore.frame.minY)], maxY [\(btnReadMore.frame.maxY)]")
        
//        txAnswer.numberOfLines = 0
    }
    
    @objc func openReadMore() {
        eventHandler.openReadMore(item: displayItem, controller: self)
    }
    
    @IBAction func touchBtnReadMore(_ sender: Any) {
        openReadMore()
    }
}
extension MaintenanceViewController: MaintenanceViewInterface {
    func dismissMaintenance() {
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: .didMaintenanceComplete, object: nil)
        }
    }
}
extension MaintenanceViewController {
    public static func viewControllerFromStoryboard() -> MaintenanceViewController {
        let storyboard = StoryboardManager.mozoStoryboard()
        let viewController = storyboard.instantiateViewController(withIdentifier: MaintenanceViewControllerIdentifier) as! MaintenanceViewController
        return viewController
    }
}
