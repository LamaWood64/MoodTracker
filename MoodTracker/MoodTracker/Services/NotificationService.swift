//
//  NotificationService.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.

import Foundation
import UserNotifications

class NotificationService {
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Permission error:", error)
            }
        }
    }
    
    func scheduleDailyReminder() {
        
        let content = UNMutableNotificationContent()
        content.title = "Mood Tracker"
        content.body = "How are you feeling now?"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 20:00 каждый день
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_mood_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
