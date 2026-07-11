//
//  ChatVM.swift
//  Marko
//
//  Created by Ivan on 07.07.2026.
//

import Foundation
import FirebaseFirestore

class ChatVM {
    
    // MARK: - Properties
    
    let chat: ChatModel
    
    private let chatRe = ChatRepo()
    private var listener: ListenerRegistration?
    
    private(set) var messages: [ChatMessage] = []
    
    var currentUserId: String {
        
        return AuthService.shared.currentUserId
        
    }
    
    // MARK: - Closures
    
    var didUpdateMessages: (() -> Void)?
    var didErrorOccur: ((String) -> Void)?
    
    // MARK: - Init
    
    init(chat: ChatModel) {
        self.chat = chat
    }
    
    // MARK: - Methods
    
    func loadMessages() {
        
        listener = chatRe.listenForMessages(channelID: chat.id, completion: { [weak self] message in // функция захватил listener по слабой ссылке или по сильной? ткаже это ссылочный тип? верно? когда функция обращается к значению наружу? еще вопрос по захвату ссылок closure там вроде как неочевидное с памятью происходит что-то что не должно оказываться в куче - там оказывается или в stack оказывается - не помню
            switch message {
            
            case .failure(let error):
                
                self?.didErrorOccur?(error.localizedDescription)
            
            case .success(let messages):
                
                DispatchQueue.main.async {
                    self?.messages = messages
                    
                    self?.didUpdateMessages?()
                }
            }
        })
    }
    
    func sendMessage(text: String) {
        
        chatRe.sendMessage(text: text, chatID: chat.id) { result in
            switch result {
            
            case.failure(let error):
                
                self.didErrorOccur?(error.localizedDescription)
                
            case .success((())):
            self.didUpdateMessages?()
            
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
