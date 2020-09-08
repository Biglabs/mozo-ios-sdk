//
//  UILabel+Copyable.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 2/22/19.
//

import Foundation
import UIKit

public class CopyableLabel: UILabel {
    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    private let selectionOverlay: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 8
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.14).cgColor
        layer.isHidden = true
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.addSublayer(selectionOverlay)
        NotificationCenter.default.addObserver(self, selector: #selector(didHideMenu), name: NSNotification.Name.UIMenuControllerDidHideMenu, object: nil)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showCopyMenu(sender:))
        ))
    }
    
    private func textRect() -> CGRect {
        let inset: CGFloat = -4
        return textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).insetBy(dx: inset, dy: inset)
    }
    
    @objc
    private func didHideMenu(_ notification: Notification) {
        selectionOverlay.isHidden = true
    }
    
    @objc
    func showCopyMenu(sender: Any?) {
        guard let text = text, !text.isEmpty else { return }
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            selectionOverlay.isHidden = false
            menu.setTargetRect(textRect(), in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    private func cancelSelection() {
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    
    public override func copy(_ sender: Any?) {
        cancelSelection()
        UIPasteboard.general.string = text ?? ""
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        selectionOverlay.frame = textRect()
    }
    
    public override func resignFirstResponder() -> Bool {
        cancelSelection()
        return super.resignFirstResponder()
    }
}
