//
//  WalletInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/13/18.
//

import Foundation

import SwiftyJSON

public class WalletInfoDTO: Codable, ResponseObjectSerializable {
    public var encryptSeedPhrase: String?
    public var offchainAddress: String?
    public var onchainAddress: String?
    public var encryptedPin: String?
    
    public required init(encryptSeedPhrase: String?, offchainAddress: String?){
        self.encryptSeedPhrase = encryptSeedPhrase
        self.offchainAddress = offchainAddress
    }
    
    public required init(encryptSeedPhrase: String?, offchainAddress: String?, onchainAddress: String?) {
        self.encryptSeedPhrase = encryptSeedPhrase
        self.offchainAddress = offchainAddress
        self.onchainAddress = onchainAddress
    }
    
    public required init(encryptSeedPhrase: String?, offchainAddress: String?, onchainAddress: String?, encryptedPin: String?) {
        self.encryptSeedPhrase = encryptSeedPhrase
        self.offchainAddress = offchainAddress
        self.onchainAddress = onchainAddress
        self.encryptedPin = encryptedPin
    }
    
    public required init(onchainAddress: String?) {
        self.onchainAddress = onchainAddress
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.encryptSeedPhrase = json["encryptSeedPhrase"].string
        self.offchainAddress = json["offchainAddress"].string
        self.onchainAddress = json["onchainAddress"].string
        self.encryptedPin = json["encryptedPin"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let encryptSeedPhrase = self.encryptSeedPhrase {
            json["encryptSeedPhrase"] = encryptSeedPhrase
        }
        if let offchainAddress = self.offchainAddress {
            json["offchainAddress"] = offchainAddress
        }
        if let onchainAddress = self.onchainAddress {
            json["onchainAddress"] = onchainAddress
        }
        if let encryptedPin = self.encryptedPin {
            json["encryptedPin"] = encryptedPin
        }
        return json
    }
    
    func rawData() -> Data? {
        let json = JSON(self.toJSON())
        return try? json.rawData()
    }
}
