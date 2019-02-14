//
//  UserProfileDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/18.
//

import Foundation
import SwiftyJSON

public class UserProfileDTO: Codable, ResponseObjectSerializable {
    public var id: Int?
    public var userId: String?
    public var status: String?
    public var phoneNumber: String?
    public var avatarUrl: String?
    public var fullName: String?
    public var birthDay: Int64?
    public var email: String?
    public var gender: Int?
    
    public var walletInfo: WalletInfoDTO?
    public var exchangeInfo: ExchangeInfoDTO?
    public var settings: String?
    
    public required init(walletInfo: WalletInfoDTO?){
        self.walletInfo = walletInfo
    }
    
    public required init(avatarUrl: String?){
        self.avatarUrl = avatarUrl
    }
    
    public required init(fullName: String?, birthDay: Int64?, email: String?, gender: Int?) {
        self.fullName = fullName
        self.birthDay = birthDay
        self.email = email
        self.gender = gender
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].int
        self.userId = json["userId"].string
        self.status = json["status"].string
        self.phoneNumber = json["phoneNumber"].string
        self.avatarUrl = json["avatarUrl"].string
        self.walletInfo = WalletInfoDTO(json: json["walletInfo"])
        self.exchangeInfo = ExchangeInfoDTO(json: json["exchangeInfo"])
        self.settings = json["settings"].string
        self.fullName = json["fullName"].string
        self.birthDay = json["birthDay"].int64
        self.email = json["email"].string
        self.gender = json["gender"].int
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let id = self.id {
            json["id"] = id
        }
        if let avatarUrl = self.avatarUrl {
            json["avatarUrl"] = avatarUrl
        }
        if let userId = self.userId {
            json["userId"] = userId
        }
        if let status = self.status {
            json["status"] = status
        }
        if let walletInfo = self.walletInfo {
            json["walletInfo"] = walletInfo.toJSON()
        }
        if let exchangeInfo = self.exchangeInfo {
            json["exchangeInfo"] = exchangeInfo.toJSON()
        }
        if let settings = self.settings {
            json["settings"] = settings
        }
        if let fullName = self.fullName {
            json["fullName"] = fullName
        }
        if let birthDay = self.birthDay {
            json["birthDay"] = birthDay
        }
        if let email = self.email {
            json["email"] = email
        }
        if let gender = self.gender {
            json["gender"] = gender
        }
        return json
    }
    
    func rawData() -> Data? {
        let json = JSON(self.toJSON())
        return try? json.rawData()
    }
}
