//
//  SessionStoreManager+Invite.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/17/19.
//

import Foundation
let KEY_DYNAMIC_LINK = "@DynamicLinkKey"
extension SessionStoreManager {
    public static func getDynamicLink() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: KEY_DYNAMIC_LINK)
    }
    
    public static func setDynamicLink(_ dynamicLink: String) {
        NSLog("SessionStoreManager - Set dynamic link: \(dynamicLink)")
        // Handle case: Receive Dynamic Link when app is running.
        if !dynamicLink.isEmpty {
            MozoSDK.processInvitationCode()
        }
        let defaults = UserDefaults.standard
        defaults.set(dynamicLink, forKey: KEY_DYNAMIC_LINK)
    }
}
