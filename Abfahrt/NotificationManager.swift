//
//  NotificationManager.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 18.02.18.
//  Copyright © 2018 Lukas Kollmer. All rights reserved.
//

import Foundation
import UserNotifications


class NotificationManager {
    static let `default` = NotificationManager()
    
    
    func removeOldNotifications() {
        // remove all already delivered notifications for departured that are in the past
        // we keep notifications for yet-to-happen departures in notification center
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let now = Date().timeIntervalSinceReferenceDate
            
            let identifiers = notifications
                .filter { now > ($0.request.content.userInfo["departureTimestamp"] as! TimeInterval) }
                .map { $0.request.identifier }
            
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }
    

    func addNotification(for departure: Departure, timeInterval: TimeInterval) {
        
        let content = UNMutableNotificationContent()
        
        content.title = departure.nicelyFormattedDescription()
        content.body  = "Departure in \(Int(timeInterval / 60)) minutes!"
        content.userInfo["departureTimestamp"] = departure.departureTime.timeIntervalSinceReferenceDate
        
        
        let triggerTimeInterval = departure.departureTime.addingTimeInterval(-timeInterval).timeIntervalSinceNow
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTimeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { success, error in
            if success {
                UNUserNotificationCenter.current().add(request) { error in}
            }
        }
    }
}
