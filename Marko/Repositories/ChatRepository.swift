//
//  ChatRepository.swift
//  Marko
//
//  Created by Ivan on 27.06.2026.
//

import Foundation
import FirebaseFirestore

class ChatRepository {
    
    let db = Firestore.firestore()
    
    
    // MARK: - Get or create channel
    func getOrCreateChannel(teacher: Teacher, completion: @escaping (Result<ChatModel, Error>) -> Void) {
        
        let currentUseId = AuthService.shared.currentUserId
        
        guard !currentUseId.isEmpty else {
            let error = NSError(domain: "ChatRepository", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            
            completion(.failure(error))
            return
        }
        
        // trying to find existing chat
        
        db.collection("channels")
            .whereField("studentId", isEqualTo: currentUseId)
            .whereField("teacherid", isEqualTo: teacher.id)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    
                    print("error")
                    completion(.failure(error))
                    return
                }
                
                if let document = snapshot?.documents.first, let channel = ChatModel(documentId: document.documentID, data: document.data()) {
                    print("ChatRepo: Found existing channel \(channel.id)")
                    completion(.success(channel))
                    return
                }
            }
        
    }
}
