//
//  ABEmptyDropDownView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/19.
//

import Foundation
protocol ABEmptyDropDownViewDelegate {
    func didTouchFindInMozoXSystem()
}
@IBDesignable class ABEmptyDropDownView: MozoView {
    @IBOutlet weak var containView: UIView!
    
    var delegate: ABEmptyDropDownViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    func setupLayout() {
        containView.roundCorners(borderColor: ThemeManager.shared.disable, borderWidth: 0.5)
        containView.layer.cornerRadius = 0
        containView.dropShadow(color: UIColor(hexString: "a8c5ec"))
        containView.layer.shadowRadius = 6
        containView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    
    @IBAction func touchBtnFind(_ sender: Any) {
        delegate?.didTouchFindInMozoXSystem()
    }
}
