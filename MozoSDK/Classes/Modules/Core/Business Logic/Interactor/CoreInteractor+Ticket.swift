//
//  CoreInteractor+Ticket.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/11/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension CoreInteractor {
    func getParkingTicketStatus(id: Int64, isIn: Bool) -> Promise<ParkingTicketStatusType> {
        return apiManager.getParkingTicketStatus(id: id, isIn: isIn)
    }
    
    func getParkingTicketByStoreId(storeId: Int64, isIn: Bool) -> Promise<TicketDTO> {
        return apiManager.getParkingTicketByStoreId(storeId: storeId, isIn: isIn)
    }
        
    func renewParkingTicket(id: Int64, vehicleTypeKey: String) -> Promise<TicketDTO> {
        return apiManager.renewParkingTicket(id: id, vehicleTypeKey: vehicleTypeKey)
    }
}
