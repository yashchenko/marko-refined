//
//  NetworkManager.swift
//  Marko
//
//  Created by Ivan on 11.06.2026.
//

import UIKit
import UserNotifications

class NotificationManager {

    // MARK: - Singleton

    static let shared = NotificationManager()

    private init() {}

    // MARK: - Request permission
    
    func requestPermission(in vc: UIViewController, completion: @escaping (Bool) -> Void) {
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            
            DispatchQueue.main.async {
                
                switch settings.authorizationStatus {
                case .notDetermined:
                    let alert = UIAlertController(title: "Never miss a lesson!", message: "Would you like us to remind you 15 minutes before your lesson starts?", preferredStyle: .alert)
                    let nowAction = UIAlertAction(title: "Not now", style: .cancel) { _ in
                        completion(false)
                    }
                    let sureAction = UIAlertAction(title: "Sure!", style: .default) { _ in
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            if let error = error {
                                print("❌ Notification Auth Error: \(error.localizedDescription)")
                            }
                            
                            DispatchQueue.main.async {
                                completion(granted)
                            }
                        }
                    }
                    
                    alert.addAction(nowAction)
                    alert.addAction(sureAction)
                    
                    vc.present(alert, animated: true) {
                        print("NetworkManager: vc present went off, this block is completion handler in trailing closure")
                    }
                    
                case .authorized, .provisional, .ephemeral:
                    completion(true)
                
                case .denied:
                    
                    completion(false)
                    
                @unknown default:
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Schedule Notification
    
    // At the time of booking we don't yet have a ready lesson structure.
    
    func scheduleLessonReminder(lessonID: String, teacherName: String, startTime: Date) {
        let center = UNUserNotificationCenter.current()
        
        // checking again if we have rights (just in case)
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("not authorized")
                return
            }
            
            // creating text of push
            let content = UNMutableNotificationContent()
            content.title = "Lesson starting soon"
            content.body = "Your lesson with \(teacherName) starts in 15 min"
            content.sound = UNNotificationSound.default
            
            // calculate 15 min before startTime
            let triggerDate = startTime.addingTimeInterval(-15 * 60)
            
            // we don't push if time already passed
            guard triggerDate > Date() else {
                
                return
            }
            
            let calendar = Calendar.current
            
            // creating alarm
            let dateComponents = calendar.dateComponents([ .year, .month, .day, .hour, .minute, .second ], from: triggerDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // packing in request and save to the system, ID of request == lessonID, so we can find and delete later
            
            let request = UNNotificationRequest(identifier: lessonID, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    
                    print("❌ Error scheduling notification: \(error.localizedDescription)")
                } else {
                    
                    print("✅ Notification scheduled for: \(triggerDate)")
                }
            }
            
        }
        
    }
    
    // MARK: - Cancel notification (for future use)
    
    // using whrn student cancel lesson
    func cancelReminder(for lessonID: String) {
        let center = UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(withIdentifiers: [lessonID])
        
        print("🗑 Canceled notification for lesson: \(lessonID)")
    }
}
