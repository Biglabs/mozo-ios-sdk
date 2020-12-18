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

public enum PromotionTarget: String {
    case NONCE = "NONCE"
    case ONCE_PER_USER = "ONCE_PER_USER"
    case ONCE_PER_DAY = "ONCE_PER_DAY"
    case ONCE_NEW_USER_OF_STORE = "ONCE_NEW_USER_OF_STORE"
    case ONCE_NEW_REGISTER = "ONCE_NEW_REGISTER"
    
    public var display: String {
        switch self {
            case .NONCE: return "promo_restrict_none"
            case .ONCE_PER_USER: return "promo_restrict_once_per_user"
            case .ONCE_PER_DAY: return "promo_restrict_once_per_day"
            case .ONCE_NEW_USER_OF_STORE: return "promo_restrict_once_new_user_of_store"
            case .ONCE_NEW_REGISTER: return "promo_restrict_once_per_new_register_user"
        }
    }
    
    public var message: String {
        switch self {
            case .NONCE: return "promo_restrict_none"
            case .ONCE_PER_USER: return "promo_restrict_once_per_user_msg"
            case .ONCE_PER_DAY: return "promo_restrict_once_per_day_msg"
            case .ONCE_NEW_USER_OF_STORE: return "promo_restrict_once_new_user_of_store_msg"
            case .ONCE_NEW_REGISTER: return "promo_restrict_once_per_new_register_user_msg"
        }
    }
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
    case OTHERBRANCH = "OTHER_BRANCH"
    case SCANNED = "SCANNED"
    case SUCCEED = "SUCCEED"
}

public enum PromotionStatusRequestEnum : String {
    case RUNNING = "RUNNING"
    case SCHEDULE = "SCHEDULE"
    case ENDED = "ENDED"
    case EXPIRED = "EXPIRED"
    case LATEST = "LATEST"
    
    public var displayText: String {
        switch self {
        case .RUNNING: return "REDEEM"
        case .SCHEDULE: return "COMING SOON"
        default: return rawValue
        }
    }
}

public enum PromotionListTypeEnum: String {
    case TOP = "TOP"
    case COMINGSOON = "COMINGSOON"
    case HASHTAG = "HASHTAG"
    case RECOMMEND = "RECOMMEND"
    case LATEST = "LATEST"
    case END = "END"
    case RUNNING = "RUNNING"
    case RUNNING_OR_SCHEDULED = "RUNNING_OR_SCHEDULED"
    
    public var loadMoreDisplayText: String {
        switch self {
        case .TOP: return "There are a lot of Top Promotion Events"
        case .COMINGSOON: return "There are a lot of Coming Soon Promotion Events"
        case .HASHTAG: return "There are a lot of Hashtag Promotion Events"
        case .RECOMMEND: return "There are a lot of Recommend Promotion Events"
        case .LATEST: return "There are a lot of Latest Promotion Events"
        case .END: return "There are a lot of Past Promotion Events"
        case .RUNNING: return "There are a lot of Running Promotion Events"
        default: return ""
        }
    }
    
    public var displayText: String {
        switch self {
        case .TOP: return "Top Promotions"
        case .COMINGSOON: return "Coming Soon"
        case .HASHTAG: return "Hashtag"
        case .RECOMMEND: return "Recommendation"
        case .LATEST: return "Latest Promotions"
        case .END: return "Past Promotions"
        case .RUNNING: return "Running Promotions"
        default: return ""
        }
    }
}
