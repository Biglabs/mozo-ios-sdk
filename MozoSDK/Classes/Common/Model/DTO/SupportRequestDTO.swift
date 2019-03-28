//
//  SupportRequestDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/28/19.
//

import Foundation
import SwiftyJSON

public class SupportRequestDTO: ResponseObjectSerializable {
    public var name: String?
    public var phone: String?
    public var email: String?
    public var message: String?
    public var deviceInfo: String?
    public var appVersion: String?
    public var macAddress: String?
    
    public required init(name: String?, phone: String?, email: String?, message: String?, deviceInfo: String?, appVersion: String?, macAddress: String?) {
        self.name = name
        self.phone = phone
        self.email = email
        self.message = message
        self.deviceInfo = deviceInfo
        self.appVersion = appVersion
        self.macAddress = macAddress
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.name = json["name"].string
        self.phone = json["phone"].string
        self.email = json["email"].string
        self.message = json["message"].string
        self.deviceInfo = json["deviceInfo"].string
        self.appVersion = json["appVersion"].string
        self.macAddress = json["macAddress"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let name = self.name {
            json["name"] = name
        }
        if let phone = self.phone {
            json["phone"] = phone
        }
        if let email = self.email {
            json["email"] = email
        }
        if let message = self.message {
            json["message"] = message
        }
        if let deviceInfo = self.deviceInfo {
            json["deviceInfo"] = deviceInfo
        }
        if let appVersion = self.appVersion {
            json["appVersion"] = appVersion
        }
        if let macAddress = self.macAddress {
            json["macAddress"] = macAddress
        }
        return json
    }
}
