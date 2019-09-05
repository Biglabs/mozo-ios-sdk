//
//  AddressBookImportProcessDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/27/19.
//

import Foundation
import SwiftyJSON

public class AddressBookImportProcessDTO: ResponseObjectSerializable {
    
    public var currentStatus: ABImportProcessEnum?
    public var updatedAt: Int64?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.currentStatus = ABImportProcessEnum(rawValue: json["currentStatus"].string ?? "")
        self.updatedAt = json["updatedAt"].int64
    }
}

