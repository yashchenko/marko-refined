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
    
    init?(id: String, data: [String: Any]) {
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
            print("❌ Lesson init failed: Missing required string fields in document \(id)")
            return nil
        }
        
        // ШАГ 2: Достаём Timestamp поля и конвертируем в Date
        // Firestore хранит даты как объекты типа Timestamp
        // Метод .dateValue() превращает Timestamp → Date
        
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
