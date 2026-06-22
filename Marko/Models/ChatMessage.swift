//
//  ChatMessage.swift
//  Marko
//
//  Created by Ivan on 22.06.2026.
//

import Foundation
import FirebaseFirestore

struct ChatMessage {
    
    let id: String
    let channelID: String
    let senderID: String
    let text: String
    let timeStamp: Date
    
    init?(documentId: String, data: [String: Any]) {
        guard let chanelId = data["channelId"] as? String, let senderId = data["senderId"] as? String, let text = data["text"] as? String, let timeStamp = data["timestamp"] as? Timestamp else { print("chat message model failed to create instance")
            return nil }
        
        self.id = documentId
        self.channelID = chanelId
        self.senderID = senderId
        self.text = text
        self.timeStamp = timeStamp.dateValue()
        
    }
}
