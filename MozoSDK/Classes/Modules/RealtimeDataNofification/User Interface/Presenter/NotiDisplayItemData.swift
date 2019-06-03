//
//  NotiDisplayItemData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/16/18.
//

import Foundation

public class NotiDisplayItemData {
    public var displayItem : NotiDisplayItem?
    
    public init(rawNoti: RdNotification) {
        if let user = SessionStoreManager.loadCurrentUser(), let address = user.profile?.walletInfo?.offchainAddress {
            var title = ""
            var subtitle = ""
            var body = ""
            var image = ""
            var actionText = ""
            var amountText = ""
            var detailText = ""
            var summaryArgumentCount = 0
            var category = NotificationCategoryType.Default
            switch rawNoti.event {
            case NotificationEventType.BalanceChanged.rawValue, NotificationEventType.Airdropped.rawValue, NotificationEventType.AirdropInvite.rawValue:
                if let blNoti = rawNoti as? BalanceNotification {
                    var prefix = "From"
                    var displayAddress = blNoti.from
                    var action = TransactionType.Received.value
                    category = .Balance_Changed_Received
                    if blNoti.from?.lowercased() == address.lowercased() {
                        category = .Balance_Changed_Sent
                        action = TransactionType.Sent.value
                        prefix = "To"
                        displayAddress = blNoti.to
                    }
                    action = action.localized
                    prefix = prefix.localized
                    actionText = action.localized
                    let amount = blNoti.amount?.convertOutputValue(decimal: blNoti.decimal ?? 0)
                    amountText = "%@ MozoX".localizedFormat((amount ?? 0.0).roundAndAddCommas())
                    title = "\(action) %@ MozoX".localizedFormat((amount ?? 0.0).roundAndAddCommas())
                    if let airdropNoti = rawNoti as? AirdropNotification {
                        subtitle = "\(prefix) \(airdropNoti.storeName ?? "")"
                        image = "ic_notif_airdropped"
                        category = .Airdropped
                    } else if let inviteNoti = rawNoti as? InviteNotification {
                        subtitle = inviteNoti.phoneNumSignUp != nil ? "%@ joined MozoX".localizedFormat(inviteNoti.phoneNumSignUp ?? "") : "Your friend joined MozoX".localized
                        detailText = subtitle
                        image = "ic_notif_invite"
                        category = .AirdropInvite
                    } else {
                        let displayName = DisplayUtils.buildNameFromAddress(address: displayAddress ?? "")
                        subtitle = "\(prefix) \(displayName)"
                        image = "ic_notif_received"
                    }
                    summaryArgumentCount = Int(amount ?? 0)
                }
    
            case NotificationEventType.CustomerCame.rawValue:
                if let ccNoti = rawNoti as? CustomerComeNotification {
                    title = ((ccNoti.isComeIn ?? false) ? "Customers arrived" : "Customers departed").localized
                    category = ((ccNoti.isComeIn ?? false) ? .Customer_Came_In : .Customer_Came_Out)
                    actionText = title
                    image = "ic_notif_user_come"
                    body = ccNoti.phoneNo?.censoredMiddle() ?? ""
                    detailText = body
                    summaryArgumentCount = (ccNoti.isComeIn ?? false) ? 1 : 0
                }
                break
            case NotificationEventType.AirdropFounder.rawValue,
                 NotificationEventType.AirdropSignup.rawValue,
                 NotificationEventType.AirdropTopRetailer.rawValue:
                if let blNoti = rawNoti as? BalanceNotification {
                    let amount = blNoti.amount?.convertOutputValue(decimal: blNoti.decimal ?? 0)
                    title = "You got %@ Bonus MozoX".localizedFormat((amount ?? 0.0).roundAndAddCommas())
                    actionText = title // To display on Retailer App - Notification List
                    image = "ic_notif_open_box"
                    switch rawNoti.event {
                    case NotificationEventType.AirdropFounder.rawValue:
                        subtitle = "For being verified store".localized
                        break
                    case NotificationEventType.AirdropSignup.rawValue:
                        subtitle = "For signing up with us".localized
                        break
                    case NotificationEventType.AirdropTopRetailer.rawValue:
                        subtitle = "For being a 1st 1,000 MozoX Retailers".localized
                        break
                    default:
                        break
                    }
                    detailText = subtitle
                }
                break
            default:
                break
            }
            displayItem = NotiDisplayItem(event: NotificationEventType(rawValue: rawNoti.event!)!, title: title, subTitle: subtitle, body: body, image: image, actionText: actionText, amountText: amountText, detailText: detailText, summaryArgumentCount: summaryArgumentCount, categoryType: category)
        }
    }
}
