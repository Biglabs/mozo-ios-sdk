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
    @IBOutlet weak var imgViewMaintenanceWidthConstraint: NSLayoutConstraint! // Default 157
    @IBOutlet weak var imgViewMaintenanceHeightConstraint: NSLayoutConstraint! // Default 160
    @IBOutlet weak var imgViewMaintenance: UIImageView!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint! // Default 48
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint! // Default 44
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgQuestion: UIImageView!
    @IBOutlet weak var lbQuestionTitle: UILabel!
    @IBOutlet weak var lbAnswer: UILabel!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var imgArrow: UIImageView!
    
    var mainViewBorder: UIView!
    
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
        print("MaintenanceViewController - View did layout subviews")
        super.viewDidLayoutSubviews()
        
        let rectShadow = CGRect(x: 0, y: 0, width: mainViewBorder.bounds.width, height: mainViewBorder.bounds.height)
        print("Rect shadow: \(rectShadow)")
        mainViewBorder.layer.shadowPath = UIBezierPath(rect: rectShadow).cgPath
        
        
        print("Label title, minY [\(lbQuestionTitle.frame.minY)], maxY [\(lbQuestionTitle.frame.maxY)]")
        
        print("Label answer, minY [\(lbAnswer.frame.minY)], maxY [\(lbAnswer.frame.maxY)]")
        
        print("Button read more, minY [\(btnReadMore.frame.minY)], maxY [\(btnReadMore.frame.maxY)]")
    }
    
    func setupLayout() {
        containerView.roundCorners(cornerRadius: 0.015, borderColor: .clear, borderWidth: 0.1)
        containerView.layer.cornerRadius = 6
        
        mainViewBorder = UIView(frame: CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width + 16, height: containerView.frame.height + 16))
        mainViewBorder.backgroundColor = .clear
        view.insertSubview(mainViewBorder, belowSubview: containerView)

        mainViewBorder.dropShadow()
        mainViewBorder.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        mainViewBorder.layer.shadowRadius = 3.0
        mainViewBorder.layer.shadowColor = UIColor(hexString: "b9c1cc").cgColor
        
        mainViewBorder.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints([
            NSLayoutConstraint(item: mainViewBorder, attribute: .centerX, relatedBy: .equal, toItem: self.containerView, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: mainViewBorder, attribute: .top, relatedBy: .equal, toItem: self.containerView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: mainViewBorder, attribute: .width, relatedBy: .equal, toItem: self.containerView, attribute: .width, multiplier: 1.0,  constant: 16),
            NSLayoutConstraint(item: mainViewBorder, attribute: .height, relatedBy: .equal, toItem: self.containerView, attribute: .height, multiplier: 1.0, constant: 8)
            ])
        
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
            imgViewMaintenanceWidthConstraint.constant = 157 / 2
            imgViewMaintenanceHeightConstraint.constant = 160 / 2
            containerViewTopConstraint.constant = 48 / 2
            containerViewBottomConstraint.constant = 44 / 2
        }
        
        displayItem = displayData.randomItem()
        lbQuestionTitle.text = displayItem.title.localized
        
        let displayText = displayItem.answer.localized
        lbAnswer.text = displayText
        
//        let lbWidth = UIScreen.main.bounds.width
//        let fontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
//        let size = displayText.size(withAttributes: fontAttributes)
        
        print("Label title, minY [\(lbQuestionTitle.frame.minY)], maxY [\(lbQuestionTitle.frame.maxY)]")
        
        print("Label answer, minY [\(lbAnswer.frame.minY)], maxY [\(lbAnswer.frame.maxY)]")
        
        print("Button read more, minY [\(btnReadMore.frame.minY)], maxY [\(btnReadMore.frame.maxY)]")
        
        lbAnswer.numberOfLines = 0
    }
    
    @objc func openReadMore() {
        eventHandler.openReadMore(item: displayItem)
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
