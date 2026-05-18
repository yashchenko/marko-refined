//
//  Lesson.swift
//  Marko
//
//  Created by Ivan on 01.09.2025.
//

import Foundation
import FirebaseFirestore

struct Lesson {
    let id: String
    let userId: String
    let teacherId: String
    let timeSlotId: String
    let teacherName: String
    let teacherProfileImageURL: String
    let subject: String
    let studentInitials: String
    let startTime: Date
    let endTime: Date
    let pricePaidByStudent: Double
    let currency: String
    let status: LessonStatus
    let meetingLink: String?
    
    init?(id: String, data: [String: Any]) {
            // ШАГ 1: Достаём строковые поля
            if data["studentId"] as? String == nil { print("❌ Missing: studentId in \(id)") }
            if data["teacherId"] as? String == nil { print("❌ Missing: teacherId in \(id)") }
            if data["timeSlotId"] as? String == nil { print("❌ Missing: timeSlotId in \(id)") }
            if data["teacherName"] as? String == nil { print("❌ Missing: teacherName in \(id)") }
            if data["teacherProfileImageURL"] as? String == nil { print("❌ Missing: teacherProfileImageURL in \(id)") }
            if data["subject"] as? String == nil { print("❌ Missing: subject in \(id)") }
            if data["currency"] as? String == nil { print("❌ Missing: currency in \(id)") }
            if data["status"] as? String == nil { print("❌ Missing: status in \(id)") }

            guard
                let studentId = data["studentId"] as? String,
                let teacherId = data["teacherId"] as? String,
                let timeSlotId = data["timeSlotId"] as? String,
                let teacherName = data["teacherName"] as? String,
                let teacherProfileImageURL = data["teacherProfileImageURL"] as? String,
                let lessonSubject = data["subject"] as? String,
                let currency = data["currency"] as? String,
                let statusString = data["status"] as? String
            else {
                return nil
            }
        
        // STEP 2: Extract Timestamp fields and convert to Date. Firestore stores dates as Timestamp objects. The .dateValue() method converts Timestamp → Date
        
        guard
            let startTimestamp = data["startTime"] as? Timestamp,
            let endTimestamp = data["endTime"] as? Timestamp
        else {
            print("❌ Lesson init failed: Missing or invalid timestamp fields in document \(id)")
            return nil
        }
        
        // ШАГ 3: Достаём числовое поле (цена)
        // Firestore может вернуть число как Double или как NSNumber
        // Безопасная конвертация: сначала пробуем Double, потом NSNumber.doubleValue
        
        guard let pricePaid = data["pricePaid"] as? Double ?? (data["pricePaid"] as? NSNumber)?.doubleValue else {
            print("❌ Lesson init failed: Missing or invalid pricePaid in document \(id)")
            return nil
        }
        
        guard let lessonStatus = LessonStatus(rawValue: statusString) else {
            
            print("❌ Lesson init failed: Invalid status '\(statusString)' in document \(id)")
            return nil
            
        }
        
        let studentInitials = data["studentInitials"] as? String ?? "?"
        
        // Парсим ссылку безопасно
        let meetingLink = data["meetingLink"] as? String
        
        
        self.id = id
        self.userId = studentId  // Маппим studentId → userId
        self.teacherId = teacherId
        self.timeSlotId = timeSlotId
        self.teacherName = teacherName
        self.teacherProfileImageURL = teacherProfileImageURL
        self.subject = lessonSubject
        self.studentInitials = studentInitials
        self.startTime = startTimestamp.dateValue()  // Конвертация Timestamp → Date
        self.endTime = endTimestamp.dateValue()      // Конвертация Timestamp → Date
        self.pricePaidByStudent = pricePaid
        self.currency = currency
        self.status = lessonStatus
        self.meetingLink = meetingLink

        // Логируем успешное создание (для отладки)
        print("✅ Lesson created: \(teacherName) on \(startTimestamp.dateValue())")
        
    }
}


enum LessonStatus: String {
    case upcoming
    case completed
    case cancelledByStudent
    case cancelledByTeacher
}


extension Lesson {
    
    // Дополнительный инициализатор для создания объекта из кэша (Core Data)
        init(id: String, userId: String, teacherId: String, timeSlotId: String,
             teacherName: String, teacherProfileImageURL: String, subject: String,
             studentInitials: String, startTime: Date, endTime: Date,
             pricePaidByStudent: Double, currency: String, status: LessonStatus, meetingLink: String?) {
            
            self.id = id
            self.userId = userId
            self.teacherId = teacherId
            self.timeSlotId = timeSlotId
            self.teacherName = teacherName
            self.teacherProfileImageURL = teacherProfileImageURL
            self.subject = subject
            self.studentInitials = studentInitials
            self.startTime = startTime
            self.endTime = endTime
            self.pricePaidByStudent = pricePaidByStudent
            self.currency = currency
            self.status = status
            self.meetingLink = meetingLink
        }
    
}
