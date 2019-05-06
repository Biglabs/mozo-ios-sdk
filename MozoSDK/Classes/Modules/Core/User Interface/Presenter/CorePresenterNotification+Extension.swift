//
//  CorePresenterNotification+Extension.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/19/18.
//

import Foundation
import UserNotifications
import SwiftyJSON
extension CorePresenter {
    func registerForRichNotifications() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            if granted {
                print("Permission granted")
            } else {
                print("Permission not granted")
            }
        }
        
        //actions defination
//        let actionView = UNNotificationAction(identifier: "actionView", title: "View".localized, options: [.foreground])
//        let actionClear = UNNotificationAction(identifier: "actionClear", title: "Clear".localized, options: [.foreground])
        
//        let eventTypes : [NotificationEventType] = [.BalanceChanged, .Airdropped, .AirdropInvite, .CustomerCame]
//        var categories = [UNNotificationCategory]()
//        for type in eventTypes {
//            let summaryFormat = type.summaryFormat.localized
//            let identifier = "mozoActionCategory_\(type.rawValue)"
//            let category = UNNotificationCategory(identifier: identifier, actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nil, categorySummaryFormat: summaryFormat, options: [])
//            categories.append(category)
//        }
//
//        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
    }
    
    func performNotifications(noti: RdNotification, rawMessage: String) {
        let displayData = NotiDisplayItemData(rawNoti: noti)
        if let displayItem = displayData.displayItem {
            let content = UNMutableNotificationContent()
            let requestIdentifier = "mozoNotification_\(Date())"
            
            content.userInfo = ["notiContent": rawMessage]
            // No need to display badge number on app
            content.badge = 0
//                NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.title = displayItem.title
            content.subtitle = displayItem.subTitle
            content.body = displayItem.body
            content.categoryIdentifier = "mozoActionCategory"
            content.sound = UNNotificationSound.default()
            
            // Group notification
//            if let event = noti.event,
//               let notiType = NotificationEventType(rawValue: event),
//               [NotificationEventType.BalanceChanged, .Airdropped, .AirdropInvite, .CustomerCame].contains(notiType) {
//                
//                content.categoryIdentifier = "mozoActionCategory_\(event)"
//                content.threadIdentifier = event.lowercased()
//                content.summaryArgumentCount = displayItem.summaryArgumentCount
//            }
            
            // If you want to attach any image to show in local notification
            if let img = UIImage(named: displayItem.image, in: BundleManager.mozoBundle(), compatibleWith: nil) {
                do {
                    let attachment = UNNotificationAttachment.create(identifier: requestIdentifier, image: img, options: nil)
                    //try? UNNotificationAttachment(identifier: requestIdentifier, url: url, options: nil)
                    content.attachments = [attachment] as! [UNNotificationAttachment]
                }
            }
            
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { (error:Error?) in
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                print("Notification Register Success")
            }
        }
    }
}

extension UNNotificationAttachment {
    
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = UIImagePNGRepresentation(image) else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
