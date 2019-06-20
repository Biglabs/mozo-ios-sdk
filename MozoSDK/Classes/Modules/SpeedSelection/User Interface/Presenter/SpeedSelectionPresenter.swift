//
//  SpeedSelectionPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
class SpeedSelectionPresenter: NSObject {
    var delegate: SpeedSelectionModuleDelegate?
}
extension SpeedSelectionPresenter: SpeedSelectionModuleInterface {
    func decideAutoWay() {
        delegate?.didSelectAutoWay()
    }
    
    func decideManualWay() {
        delegate?.didSelectManualWay()
    }
}
