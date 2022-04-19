//
//  AccessToken.swift
//  MozoSDK
//
//  Created by Vu Nguyen on 18/04/2022.
//

import Foundation
public class AccessToken {
    public let accessToken: String?
    public let expireTime: Date?
    
    public let refreshToken: String?
    public let refreshExpireTime: Date?
    
    public let idToken: String?
    
    let rawData: Data?
    
    init(_ data: [String: Any]) {
        self.rawData = try? JSONSerialization.data(withJSONObject: data)
        self.accessToken = data["access_token"] as? String
        self.refreshToken = data["refresh_token"] as? String
        
        let expireInSec = data["expires_in"] as? Double
        self.expireTime = Date(timeIntervalSinceNow: expireInSec ?? 0)
        
        let refreshExpireInSec = data["refresh_expires_in"] as? Double
        self.refreshExpireTime = Date(timeIntervalSinceNow: refreshExpireInSec ?? 0)
        
        self.idToken = data["id_token"] as? String
    }
    
    class func parse(_ data: Data) -> AccessToken? {
        guard let arr = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return AccessToken(arr)
    }
}
