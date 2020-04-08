//
//  TicketDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/30/19.
//

import Foundation
import SwiftyJSON
public enum EnoughTypeEnum: String {
    case NORMAL = "NORMAL"
    case NOT_ENOUGH_IN_TOP_UP = "NOT_ENOUGH_IN_TOP_UP"
    case NOT_ENOUGH_MOZO = "NOT_ENOUGH_MOZO"
}
public class TicketDTO: ResponseObjectSerializable {
    
    public var id: Int64?
    public var ticketId: String?
    public var otp: String?
    public var isFree: Bool?
    public var isIn: Bool?
    public var partyName: String?
    public var coverImage: String?
    public var amount: NSNumber?
    
    public var specialTicket: Bool?
    public var timeCreateOtp: Int64?

    public var branch: BranchInfoDTO?
    public var extraMozo: NSNumber?
    public var extraCash: Double?
    public var unitCurrency: String?
    public var useCash: Bool?
    public var vehicle: VehicleInfoDTO?
    
    public var expiredDate: Int64?
    public var cash: Double?
    public var enoughType: EnoughTypeEnum?
    
    public required init(partyName: String, coverImage: String) {
        self.partyName = partyName
        self.coverImage = coverImage
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].int64
        self.ticketId = json["ticketId"].string
        self.otp = json["otp"].string
        self.isFree = json["free"].bool
        self.isIn = json["in"].bool
        self.partyName = json["partyName"].string
        self.coverImage = json["coverImage"].string
        self.amount = json["amount"].number
        
        self.specialTicket = json["specialTicket"].bool
        self.timeCreateOtp = json["timeCreateOtp"].int64

        self.branch = BranchInfoDTO(json: json["branch"])
        self.extraMozo = json["extraMozo"].number
        self.extraCash = json["extraCash"].double
        self.unitCurrency = json["unitCurrency"].string
        self.useCash = json["useCash"].bool
        self.vehicle = VehicleInfoDTO(json: json["vehicle"])
        
        self.expiredDate = json["expiredDate"].int64
        self.cash = json["cash"].double
        self.enoughType = EnoughTypeEnum(rawValue: json["enoughType"].string ?? "")
    }
}

