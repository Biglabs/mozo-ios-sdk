//
//  NotiDisplayItemData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/16/18.
//

import Foundation

public class NotiDisplayItemData {
    var displayItem : NotiDisplayItem?
    
    init(rawNoti: RdNotification) {
        if let user = SessionStoreManager.loadCurrentUser(), let address = user.profile?.walletInfo?.offchainAddress {
            var title = ""
            var subtitle = ""
            var body = ""
            var image = ""
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
                    let amount = blNoti.amount?.convertOutputValue(decimal: blNoti.decimal ?? 0)
                    title = "\(action) \(amount ?? 0.0) Mozo"
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
                    title = (ccNoti.comeIn ?? false) ? "Customer come in" : "Customer has just left"
                    image = "ic_notif_user_come"
                    body = ccNoti.phoneNo ?? ""
                }
                break
            default:
                break
            }
            displayItem = NotiDisplayItem(title: title, subTitle: subtitle, body: body, image: image)
        }
    }
}
