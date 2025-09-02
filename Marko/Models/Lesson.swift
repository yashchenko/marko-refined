//
//  Lesson.swift
//  Marko
//
//  Created by Ivan on 01.09.2025.
//

import Foundation

struct Lesson {
    let id: String
    let userId: String
    let teacherId: String
    let timeSlotId: String
    let teacherName: String
    let teacherProfileImageURL: String
    let studentInitials: String
    let startTime: Date
    let endTime: Date
    let pricePaidByStudent: Double
    let currency: String
    let status: LessonStatus
}

enum LessonStatus: String { // Conforming to String for easy storage in Firestore
    case upcoming
    case completed
    case cancelledByStudent
    case cancelledByTeacher
}
