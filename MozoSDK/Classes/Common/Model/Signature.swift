//
//  Signature.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/2/18.
//

import Foundation
@objc public class Signature: NSObject {
    var tosigns : [String]?
    var signatures: [String]?
    var publicKeys: [String]?
    
    public init(tosigns: [String]) {
        super.init()
        self.tosigns = tosigns
    }
    
    init(tosigns: [String], signatures: [String], publicKeys: [String]) {
        super.init()
        self.tosigns = tosigns
        self.signatures = signatures
        self.publicKeys = publicKeys
    }
}
