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
        return apiManager.getParkingTicketByStoreId(id: storeId, isIn: isIn)
    }
    
    func getParkingTicketByStoreId(storeId: Int64) -> Promise<TicketDTO> {
        return apiManager.getParkingTicketByStoreId(id: storeId)
    }
        
    func renewParkingTicket(id: Int64, vehicleTypeKey: String, isIn: Bool) -> Promise<TicketDTO> {
        return apiManager.renewParkingTicket(id: id, vehicleTypeKey: vehicleTypeKey, isIn: isIn)
    }
}
