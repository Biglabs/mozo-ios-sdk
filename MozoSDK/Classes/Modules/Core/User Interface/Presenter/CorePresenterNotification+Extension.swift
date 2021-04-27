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
                if DisplayUtils.appType == .Shopper {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } else {
                print("Permission not granted")
            }
        }
        
        //actions defination
        // AGENDA
        let actionAgendaInfo = UNNotificationAction(identifier: NotificationActionType.Agenda_Info.identifier, title: NotificationActionType.Agenda_Info.localizedTitle, options: [.foreground])
        let actionAgendaParkingGuide = UNNotificationAction(identifier: NotificationActionType.Agenda_Parking_Guide.identifier, title: NotificationActionType.Agenda_Parking_Guide.localizedTitle, options: [.foreground])
        let actionAgendaVenue = UNNotificationAction(identifier: NotificationActionType.Agenda_Venue.identifier, title: NotificationActionType.Agenda_Venue.localizedTitle, options: [.foreground])
        
        // BEFORE EVENT
        let actionBeforeEventHallLayoutGuide = UNNotificationAction(identifier: NotificationActionType.Before_Event_Hall_Layout_Guide.identifier, title: NotificationActionType.Before_Event_Hall_Layout_Guide.localizedTitle, options: [.foreground])
        let actionBeforeEventParkingTicket = UNNotificationAction(identifier: NotificationActionType.Before_Event_Parking_Ticket.identifier, title: NotificationActionType.Before_Event_Parking_Ticket.localizedTitle, options: [.foreground])
        
        // IN STORE
        let actionInStoreHallLayoutGuide = UNNotificationAction(identifier: NotificationActionType.In_Store_Hall_Layout_Guide.identifier, title: NotificationActionType.In_Store_Hall_Layout_Guide.localizedTitle, options: [.foreground])
        let actionInStoreSafetyGuide = UNNotificationAction(identifier: NotificationActionType.In_Store_Safety_Guide.identifier, title: NotificationActionType.In_Store_Safety_Guide.localizedTitle, options: [.foreground])
        
        // HACKATHON RESULT
        let actionHackathonResult = UNNotificationAction(identifier: NotificationActionType.Hackathon_Result.identifier, title: NotificationActionType.Hackathon_Result.localizedTitle, options: [.foreground])
        
        // NOTICE
        let actionNotice = UNNotificationAction(identifier: NotificationActionType.Notice.identifier, title: NotificationActionType.Notice.localizedTitle, options: [.foreground])
        
        // FEEDBACK
        let actionFeedbackNoThanks = UNNotificationAction(identifier: NotificationActionType.Feed_Back_No_Thanks.identifier, title: NotificationActionType.Feed_Back_No_Thanks.localizedTitle, options: [.foreground])
        let actionFeedbackStart = UNNotificationAction(identifier: NotificationActionType.Feed_Back_Start.identifier, title: NotificationActionType.Feed_Back_Start.localizedTitle, options: [.foreground])
                
        let categoryTypes : [NotificationCategoryType] = [.Balance_Changed_Received, .Balance_Changed_Sent, .Airdropped, .AirdropInvite, .Customer_Came_In, .Customer_Came_Out, .Agenda, .Before_Event, .In_Store_Guide, .Hackathon_Result, .Notice, .Feedback]
        var categories = [UNNotificationCategory]()
        for type in categoryTypes {
            let identifier = type.identifier
            if type.isRemote {
                var actions = [UNNotificationAction]()
                switch type {
                case .Agenda:
                    actions = [actionAgendaInfo, actionAgendaVenue, actionAgendaParkingGuide]
                    break
                case .Before_Event:
                    actions = [actionBeforeEventHallLayoutGuide, actionBeforeEventParkingTicket]
                    break
                case .In_Store_Guide:
                    actions = [actionInStoreHallLayoutGuide, actionInStoreSafetyGuide]
                    break
                case .Hackathon_Result:
                    actions = [actionHackathonResult]
                case .Notice:
                    actions = [actionNotice]
                    break
                case .Feedback:
                    actions = [actionFeedbackNoThanks, actionFeedbackStart]
                    break
                default: break
                }
                let category = UNNotificationCategory(identifier: identifier, actions: actions, intentIdentifiers: [], options: [])
                categories.append(category)
            } else {
                if #available(iOS 12.0, *) {
                    let summaryFormat = type.summaryFormat.localized
                    let category = UNNotificationCategory(identifier: identifier, actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nil, categorySummaryFormat: summaryFormat, options: [])
                    categories.append(category)
                } else {
                    let category = UNNotificationCategory(identifier: identifier, actions: [], intentIdentifiers: [], options: [])
                    categories.append(category)
                }
            }
        }

        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
    }
    
    func performNotifications(noti: RdNotification, rawMessage: String) {
        let displayData = NotiDisplayItemData(rawNoti: noti)
        if let displayItem = displayData.displayItem {
            let content = UNMutableNotificationContent()
            let requestIdentifier = "mozoNotification_\(UUID().uuidString)"
            
            content.userInfo = ["notiContent": rawMessage]
            // No need to display badge number on app
            content.badge = 0
//                NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.title = displayItem.title
            content.subtitle = displayItem.subTitle
            content.body = displayItem.body
            content.categoryIdentifier = "mozoActionCategory"
            content.sound = UNNotificationSound.default
            
            // Group notification
            if displayItem.categoryType.needGroup {
                content.categoryIdentifier = displayItem.categoryType.identifier
                content.threadIdentifier = displayItem.categoryType.rawValue.lowercased()
                if #available(iOS 12.0, *),
                    displayItem.categoryType == .Balance_Changed_Received || displayItem.categoryType == .Balance_Changed_Sent || displayItem.categoryType == .Airdropped {
                    content.summaryArgumentCount = displayItem.summaryArgumentCount
                }
            }
            
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
            guard let imageData = image.pngData() else {
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
