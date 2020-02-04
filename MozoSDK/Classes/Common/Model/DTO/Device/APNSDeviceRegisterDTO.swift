//
//  APNSDeviceRegisterDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/31/20.
//

import Foundation
import SwiftyJSON

public class APNSDeviceRegisterDTO : ResponseObjectSerializable {
    public var appType: String?
    public var deviceModel: String?
    public var instanceId: String?
    public var os: String?
    public var osVersion: String?
    public var token: String?
    
    public required init(appType: String, instanceId: String, token: String){
        self.appType = appType
            //DisplayUtils.appType.rawValue.uppercased()
        self.deviceModel = UIDevice.modelName
        self.instanceId = instanceId
        self.os = UIDevice.current.systemName
        self.osVersion = UIDevice.current.systemVersion
        self.token = token
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.appType = json["appType"].string
        self.deviceModel = json["deviceModel"].string
        self.instanceId = json["instanceId"].string
        self.os = json["os"].string
        self.osVersion = json["osVersion"].string
        self.token = json["token"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let appType = self.appType {
            json["appType"] = appType
        }
        if let deviceModel = self.deviceModel {
            json["deviceModel"] = deviceModel
        }
        if let instanceId = self.instanceId {
            json["instanceId"] = instanceId
        }
        if let os = self.os {
            json["os"] = os
        }
        if let osVersion = self.osVersion {
            json["osVersion"] = osVersion
        }
        if let token = self.token {
            json["token"] = token
        }

        return json
    }
}
