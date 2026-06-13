//
//  NetworkManager.swift
//  Marko
//
//  Created by Ivan on 11.06.2026.
//

import UIKit
import UserNotifications

class NetworkManager {

    // MARK: - Singleton

    static let shared = NetworkManager()

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
        
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("not authorized")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Lesson starting soon"
            content.body = "Your lesson with \(teacherName) starts in 15 min"
            content.sound = UNNotificationSound.default
            
        }
        
    }
}

//    func scheduleLessonReminder(
//        lessonId: String,
//        teacherName: String,
//        startTime: Date
//    ) {
//        let center = UNUserNotificationCenter.current()
//
//        // Еще раз проверяем, есть ли права (на всякий случай)
//        center.getNotificationSettings { settings in
//
//            guard settings.authorizationStatus == .authorized else {
//                return
//            }
//
//            // 1. Создаем контент (текст пуша)
//            let content = UNMutableNotificationContent()
//            content.title = "Lesson starting soon!"
//            content.body = "Your lesson with \(teacherName) starts in 15 minutes. Get ready!"
//            content.sound = UNNotificationSound.default
//
//            // Стандартный звук уведомления
//
//            // 2. Вычисляем время (за 15 минут до startTime)
//            let triggerDate = startTime.addingTimeInterval(-15 * 60)
//
//            // Защита от багов:
//            // не ставим пуш, если время уже прошло
//            guard triggerDate > Date() else {
//                return
//            }
//
//            // 3. Создаем триггер (будильник на конкретную дату и время)
//            let calendar = Calendar.current
//
//            let dateComponents = calendar.dateComponents(
//                [
//                    .year,
//                    .month,
//                    .day,
//                    .hour,
//                    .minute,
//                    .second
//                ],
//                from: triggerDate
//            )
//
//            let trigger = UNCalendarNotificationTrigger(
//                dateMatching: dateComponents,
//                repeats: false
//            )
//
//            // 4. Упаковываем в реквест и отдаем системе
//            // ID реквеста = lessonId,
//            // чтобы мы могли найти и удалить этот пуш при отмене урока
//            let request = UNNotificationRequest(
//                identifier: lessonId,
//                content: content,
//                trigger: trigger
//            )
//
//            center.add(request) { error in
//
//                if let error = error {
//                    print("❌ Error scheduling notification: \(error.localizedDescription)")
//                } else {
//                    print("✅ Notification scheduled for \(triggerDate)")
//                }
//            }
//        }
//    }
//
//    // MARK: - 3. Cancel Notification (Для будущего использования)
//
//    /// Удаляет запланированное уведомление
//    /// (используется при отмене урока)
//    func cancelReminder(for lessonId: String) {
//
//        let center = UNUserNotificationCenter.current()
//
//        // Удаляем конкретный пуш по его ID
//        center.removePendingNotificationRequests(
//            withIdentifiers: [lessonId]
//        )
//
//        print("🗑 Canceled notification for lesson: \(lessonId)")
//    }
//}
