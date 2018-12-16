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
            switch rawNoti.event {
            case NotificationEventType.BalanceChanged.rawValue, NotificationEventType.Airdropped.rawValue:
                if let blNoti = rawNoti as? BalanceNotification {
                    var prefix = "From"
                    var displayAddress = blNoti.from
                    var action = TransactionType.Received.value
                    if blNoti.from?.lowercased() == address.lowercased() {
                        action = TransactionType.Sent.value
                        prefix = "To"
                        displayAddress = blNoti.to
                    }
                    actionText = action
                    let amount = blNoti.amount?.convertOutputValue(decimal: blNoti.decimal ?? 0)
                    amountText = "\(amount ?? 0.0) Mozo"
                    title = "\(action) \(amountText)"
                    if let airdropNoti = rawNoti as? AirdropNotification {
                        subtitle = "\(prefix) \(airdropNoti.storeName ?? "NO NAME")"
                        image = "ic_notif_airdropped"
                    } else {
                        let displayName = DisplayUtils.buildNameFromAddress(address: displayAddress ?? "")
                        subtitle = "\(prefix) \(displayName)"
                        image = "ic_notif_received"
                    }
                    
                }
            case NotificationEventType.CustomerCame.rawValue:
                if let ccNoti = rawNoti as? CustomerComeNotification {
                    title = (ccNoti.isComeIn ?? false) ? "Customer come in" : "Customer has just left"
                    actionText = title
                    image = "ic_notif_user_come"
                    body = ccNoti.phoneNo ?? ""
                    detailText = body
                }
                break
            default:
                break
            }
            displayItem = NotiDisplayItem(event: NotificationEventType(rawValue: rawNoti.event!)!, title: title, subTitle: subtitle, body: body, image: image, actionText: actionText, amountText: amountText, detailText: detailText)
        }
    }
}
