//
//  CovidWarningNotification.swift
//  MozoSDK
//
//  Created by Vu Nguyen on 8/27/20.
//

import Foundation
import SwiftyJSON
public class CovidWarningNotification : RdNotification {
    public var numNewWarningZone: Int?
    
    public required init? (json: SwiftyJSON.JSON) {
        self.numNewWarningZone = json["numNewWarningZone"].int
        super.init(json: json)
    }
}
