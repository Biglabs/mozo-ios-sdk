//
//  ResponseObjectSerializable.swift
//  Pods
//
//  Created by MAC on 22/07/2022.
//

import Foundation
import SwiftyJSON

public protocol ResponseObjectSerializable: AnyObject {
    init?(json: JSON)
}
