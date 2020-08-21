//
//  CovidZone.swift
//  Pods
//
//  Created by Vu Nguyen on 8/20/20.
//

import Foundation
import SwiftyJSON

public class CovidZone {
    public var name: String?
    public var numPatient: Int?
    public var latitude: Double?
    public var longitude: Double?
    public var radius: Double?
    public var sourceUrl: String?
    public var toTime: Double?
    
    var tStartDate: Double?
    var tEndDate: Double?
    var daysLeft: Int?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.name = json["name"].string
        self.numPatient = json["numPatient"].int
        self.latitude = json["latitude"].double
        self.longitude = json["longitude"].double
        self.radius = json["radius"].double
        self.sourceUrl = json["sourceUrl"].string
        self.toTime = json["toTime"].double
    }
    
    public func startDate() -> Double {
        if let time = tStartDate {
            return time
        } else {
            let date = Date(timeIntervalSince1970: toTime ?? 0)
            tStartDate = (Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date).timeIntervalSince1970
            return tStartDate!
        }
    }
    
    public func endDate() -> Double {
        if let time = tEndDate {
            return time
        } else {
            var dateComponent = DateComponents()
            dateComponent.day = Configuration.MAX_DAY_OF_COVID
            
            let date = Date(timeIntervalSince1970: startDate())
            let datePadding = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
            tEndDate = (Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: datePadding) ?? date).timeIntervalSince1970
            return tEndDate!
        }
    }
    
    public func countToEnd() -> Int {
        if let days = daysLeft {
            return days
        } else {
            let now = (Calendar.current.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: Date()
                ) ?? Date()).timeIntervalSince1970
            
            let duration = (endDate() - now) / (24.0 * 60 * 60)
            let durationRouned = Int(duration)
            
            daysLeft = (duration / Double(durationRouned)) > 1.0 ? durationRouned + Int(duration / duration.magnitude) : durationRouned
            return daysLeft!
        }
    }
    
    public func passedDays() -> Int {
        return Configuration.MAX_DAY_OF_COVID - countToEnd()
    }
    
    public var icon: String {
        let count = countToEnd()
        switch count {
            case let(day) where day > 10: return "ic_covid_red"
            case let(day) where day > 0: return "ic_covid_blue"
            default: return "ic_covid_gray"
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        json["name"] = self.name
        json["numPatient"] = self.numPatient
        json["latitude"] = self.latitude
        json["longitude"] = self.longitude
        json["radius"] = self.radius
        json["sourceUrl"] = self.sourceUrl
        json["toTime"] = self.toTime
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [CovidZone] {
        let array = json.array?.map({ CovidZone(json: $0)! })
        return array ?? []
    }
}
