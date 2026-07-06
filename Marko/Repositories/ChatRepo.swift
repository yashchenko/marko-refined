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
        
        chatRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
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
    
    // MARK: - Send message
    
    func sendMessage(text: String, chatID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // check if user are logged in
        
        let currentUserId = AuthService.shared.currentUserId
        
        guard !currentUserId.isEmpty else {
            let error = NSError(domain: "ChatRepo", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unathorized 🐕"])
            completion(.failure(error))
            return
        }
        
        // validation text, we check and if there any spaces
        
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanText.isEmpty else {
            
            let error = NSError(domain: "ChatRepo", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot be empty 🐕"])
            completion(.failure(error))
            return
        }
        
        // A reference to a subcollection of messages within a specific chat
        let messageRef = db.collection("channels").document(chatID).collection("messages").document()
        
        let messageData: [String: Any] = [
        
            "channelId": chatID,
            "senderId": currentUserId,
            "text": cleanText,
            "timestamp": FieldValue.serverTimestamp()
        
        ]
        
        // Link to the channel itself (to update the preview of the latest message)
        let chatRef = db.collection("channels").document(chatID)
        
        // Atomic Write: Either everything is written together, or nothing
        let batch = db.batch()
        
        batch.setData(messageData, forDocument: messageRef)
        
        batch.updateData([
            "lastMessageText": cleanText,
            "lastMessageDate": FieldValue.serverTimestamp()
        
        
        ], forDocument: chatRef)
        
        batch.commit { error in
            if let error = error {
                print("❌ ChatRepo: Failed to send message: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Real Time Listener
    
    func listenForMessages(channelID: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration {
        
        // Added a limit of 50 latest messages to avoid downloading thousands of old documents
        
        let query = db.collection("channels").document(channelID).collection("messages").order(by: "timestamp", descending: false).limit(to: 50)
        
        let listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                
                completion(.success([]))
                return
            }
            
            let messages = documents.compactMap { doc -> ChatMessage? in
                return ChatMessage(documentId: doc.documentID, data: doc.data())
            }
            
            
            completion(.success(messages))
        }
        
        return listener
        
        
    }
    
}
