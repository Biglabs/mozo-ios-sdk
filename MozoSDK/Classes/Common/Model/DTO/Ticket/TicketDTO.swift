//
//  TicketDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/30/19.
//

import Foundation
import SwiftyJSON
public class TicketDTO: ResponseObjectSerializable {
    
    public var id: Int64?
    public var ticketId: String?
    public var otp: String?
    public var isFree: Bool?
    public var isIn: Bool?
    public var partyName: String?
    public var coverImage: String?
    public var amount: NSNumber?
    
    public required init(partyName: String, coverImage: String) {
        self.partyName = partyName
        self.coverImage = coverImage
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].int64
        self.ticketId = json["ticketId"].string
        self.otp = json["otp"].string
        self.isFree = json["isFree"].bool
        self.isIn = json["in"].bool
        self.partyName = json["partyName"].string
        self.coverImage = json["coverImage"].string
        self.amount = json["amount"].number
    }
}

