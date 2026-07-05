//
//  ChatRepo.swift
//  Marko
//
//  Created by Ivan on 05.07.2026.
//

import Foundation
import FirebaseFirestore

class ChatRepo {
    
    // MARK: - Properties
    
    let db = Firestore.firestore()
    
    // MARK: - Methods
    
    func getOrCreateChat(teacher: Teacher, completion: @escaping (Result<ChatModel, Error>) -> Void) {
        
        let currentUserId = AuthService.shared.currentUserId
        
        guard !currentUserId.isEmpty else {
            
            let error = NSError(domain: "ChatRepo", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(.failure(error))
            return
        }
        
        let channelID = "\(currentUserId)_\(teacher.id)"
        let chatRef = db.collection("channels").document(channelID)
        
        chatRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let doc = snapshot, doc.exists, let chat = ChatModel(documentId: doc.documentID, data: doc.data() ?? [:]) {
                print("💬 ChatRepo: Found existing channel \(channelID)")
                completion(.success(chat))
                return
            }
            
            // if not find creating new one by existing ID
            
            print("🆕 ChatRepo: Channel not found. Creating new one with ID: \(channelID)")
            self.createNewChat(chatRef: chatRef, studentID: currentUserId, teacher: teacher, completion: completion)
        }
    }
    
    func createNewChat(chatRef: DocumentReference, studentID: String, teacher: Teacher, completion: @escaping (Result<ChatModel, Error>) -> Void) {
        let authUser = AuthService.shared.currentUser
        let pseudonym = authUser?.email?.components(separatedBy: "@").first ?? "Student" // here ticket: replace "student" by pseudonym like in habr pseudonym
        let studentName = authUser?.displayName ?? pseudonym
        
        let chatData: [String: Any] = [
        
            "studentId": studentID,
            "teacherId": teacher.id,
            "studentName": studentName,
            "teacherName": teacher.name,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        chatRef.setData(chatData) { error in
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                let newChat = ChatModel(id: chatRef.documentID, studentId: studentID, teacherId: teacher.id, teacherName: teacher.name, studentName: studentName, lastMessageText: nil, lastMessageDate: nil)
                completion(.success(newChat))
            }
            
            
        }
        
        
        
        
    }
}
