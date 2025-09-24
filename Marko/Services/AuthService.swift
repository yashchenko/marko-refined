//
//  AuthService.swift
//  Marko
//
//  Created by Ivan on 14.09.2025.
//

import Foundation
import Firebase

class AuthService {
    
    static let shared = AuthService()
    
    private(set) var currentUser: FirebaseAuth.User? // keep current user
    
    var onAuthStsteChanged: ((FirebaseAuth.User?) -> Void)? // closure for notifications
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        
        addAuthStateListener()
    }
    
    private func addAuthStateListener() {
        
        authStateHandle = Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            
            self?.currentUser = user
            self?.onAuthStsteChanged?(user)
            
            
            if let user = user {
                print("AuthService: User is signed in with UID: \(user.uid)")
            } else {
                
                print("AuthService: User is signed out.")
            }
            
        })
        
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            print("AuthService: Auth state listener removed.")
        }
    }
}
