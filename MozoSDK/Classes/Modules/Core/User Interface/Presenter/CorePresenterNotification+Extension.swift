//
//  CorePresenterNotification+Extension.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/19/18.
//

import Foundation
import UserNotifications

extension CorePresenter: UNUserNotificationCenterDelegate {
    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification center: displaying notification when app is in foreground")
        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.
        
        completionHandler([.alert, .badge, .sound])
    }
    
    // For handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification center: handling tap and user actions")
        switch response.actionIdentifier {
        case "actionView":
            print("Action View Tapped")
        case "actionClear":
            print("Action Clear Tapped")
        default:
            break
        }
        completionHandler()
    }
}

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
        let action1 = UNNotificationAction(identifier: "actionView", title: "View".localized, options: [.foreground])
        let action2 = UNNotificationAction(identifier: "actionClear", title: "Clear".localized, options: [.foreground])
        
        let category = UNNotificationCategory(identifier: "mozoActionCategory", actions: [action1,action2], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
    
    func performNotifications(noti: RdNotification) {
        let displayData = NotiDisplayItemData(rawNoti: noti)
        if let displayItem = displayData.displayItem {
            let content = UNMutableNotificationContent()
            let requestIdentifier = "mozoNotification_\(Date())"
            
            content.badge = 1
            content.title = displayItem.title
            content.subtitle = displayItem.subTitle
            content.body = displayItem.body
            content.categoryIdentifier = "mozoActionCategory"
            content.sound = UNNotificationSound.default()
            
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
