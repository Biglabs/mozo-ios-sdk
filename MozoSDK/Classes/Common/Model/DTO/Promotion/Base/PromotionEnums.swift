//
//  PromotionEnums.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/8/19.
//

import Foundation
public enum PromotionStatusEnum: String {
    case SCHEDULE = "SCHEDULE"
    case ACTIVE = "ACTIVE"
    case END = "END"
    case FINISH = "FINISH"
}

public enum PromotionTypeEnum: String {
    case DURATION = "DURATION"
    case FIRST = "FIRST"
    case ARCHIVERMENT = "ARCHIVERMENT"
}

public enum PromotionStatusCode: String {
    case AVAILABLE = "AVAILABLE"
    case USED = "USED"
    case EXPIRED = "EXPIRED"
    case OTHERSTORE = "OTHERSTORE"
    case SCANNED = "SCANNED"
    case SUCCEED = "SUCCEED"
}

public enum PromotionStatusRequestEnum : String {
    case RUNNING = "RUNNING"
    case ENDED = "ENDED"
    case SCHEDULE = "SCHEDULE"
    case EXPIRED = "EXPIRED"
    
    public var displayText: String {
        switch self {
        case .RUNNING: return "REDEEM"
        case .SCHEDULE: return "COMING SOON"
        case .ENDED, .EXPIRED: return rawValue
        }
    }
}

public enum PromotionListTypeEnum: String {
    case TOP = "TOP"
    case COMINGSOON = "COMINGSOON"
    case HASHTAG = "HASHTAG"
    case RECOMMEND = "RECOMMEND"
    
    public var loadMoreDisplayText: String {
        switch self {
        case .TOP: return "There are a lot of Top Promotion Events"
        case .COMINGSOON: return "There are a lot of Coming Soon Promotion Events"
        case .HASHTAG: return "There are a lot of Hashtag Promotion Events"
        case .RECOMMEND: return "There are a lot of Recommend Promotion Events"
        }
    }
    
    public var displayText: String {
        switch self {
        case .TOP: return "Top Promotions"
        case .COMINGSOON: return "Coming Soon"
        case .HASHTAG: return "Hashtag"
        case .RECOMMEND: return "Recommendation"
        }
    }
}
