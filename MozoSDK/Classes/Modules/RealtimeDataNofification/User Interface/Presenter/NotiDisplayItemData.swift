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
            switch rawNoti.event {
            case NotificationEventType.BalanceChanged.rawValue, NotificationEventType.Airdropped.rawValue, NotificationEventType.AirdropInvite.rawValue:
                if let blNoti = rawNoti as? BalanceNotification {
                    var prefix = "From"
                    var displayAddress = blNoti.from
                    var action = TransactionType.Received.value
                    if blNoti.from?.lowercased() == address.lowercased() {
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
                    } else if let inviteNoti = rawNoti as? InviteNotification {
                        subtitle = inviteNoti.phoneNumSignUp != nil ? "%@ joined MozoX".localizedFormat(inviteNoti.phoneNumSignUp ?? "") : "Your friend joined MozoX".localized
                        detailText = subtitle
                        image = "ic_notif_invite"
                    } else {
                        let displayName = DisplayUtils.buildNameFromAddress(address: displayAddress ?? "")
                        subtitle = "\(prefix) \(displayName)"
                        image = "ic_notif_received"
                    }
                    summaryArgumentCount = Int(amount ?? 0)
                }
    
            case NotificationEventType.CustomerCame.rawValue:
                if let ccNoti = rawNoti as? CustomerComeNotification {
                    title = ((ccNoti.isComeIn ?? false) ? "Customer has entered" : "Customer has left").localized
                    actionText = title
                    image = "ic_notif_user_come"
                    body = ccNoti.phoneNo?.censoredMiddle() ?? ""
                    detailText = body
                    summaryArgumentCount = (ccNoti.isComeIn ?? false) ? 1 : 0
                }
                break
            default:
                break
            }
            displayItem = NotiDisplayItem(event: NotificationEventType(rawValue: rawNoti.event!)!, title: title, subTitle: subtitle, body: body, image: image, actionText: actionText, amountText: amountText, detailText: detailText, summaryArgumentCount: summaryArgumentCount)
        }
    }
}
