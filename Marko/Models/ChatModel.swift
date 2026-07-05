//
//  ChatModel.swift
//  Marko
//
//  Created by Ivan on 18.06.2026.
//

import Foundation
import FirebaseFirestore


struct ChatModel {
    
    let id: String
    let studentId: String
    let teacherId: String
    let teacherName: String
    let studentName: String
    let lastMessageText: String?
    let lastMessageDate: Date?
    
    
    init?(documentId: String, data: [String: Any]) {
        
        guard let studentId = data["studentId"] as? String, let teacherId = data["teacherId"] as? String, let teacherName = data["teacherName"] as? String, let studentName = data["studentName"] as? String else { print("❌ ChatModel init failed: Missing required fields for document \(documentId.description)")
            return nil }
        
        self.id = documentId
        self.studentId = studentId
        self.teacherId = teacherId
        self.teacherName = teacherName
        self.studentName = studentName
        
        
        self.lastMessageText = data["lastMessageText"] as? String
        
        if let time = data["lastMessageDate"] as? Timestamp {
            
            self.lastMessageDate = time.dateValue()
            
        } else {
            
            
            print("ChatModel: failed to assign time in init")
            self.lastMessageDate = nil
            
        }
    }
    
    init(id: String, studentId: String, teacherId: String, teacherName: String, studentName: String, lastMessageText: String?, lastMessageDate: Date?) {
        
        self.id = id
        self.studentId = studentId
        self.teacherId = teacherId
        self.teacherName = teacherName
        self.studentName = studentName
        self.lastMessageText = lastMessageText
        self.lastMessageDate = lastMessageDate
        
    }
}
