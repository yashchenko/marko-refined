//
//  AuthService.swift
//  Marko
//
//  Created by Ivan on 14.09.2025.
//

import Foundation
import FirebaseAuth

class AuthService {

    static let shared = AuthService()

    private(set) var currentUser: FirebaseAuth.User?

    // Уведомление об изменении статуса (вошел/вышел)
    var onAuthStateChanged: ((FirebaseAuth.User?) -> Void)?

    // Храним handle слушателя, чтобы потом удалить его в deinit
    private var authStateHandle: AuthStateDidChangeListenerHandle?


    // MARK: - Init
    private init () {

        setupAuthStateListener()

    }

    var isLoggedIn: Bool {

        return currentUser != nil
    }

    var currentUserId: String {

        // Теперь возвращаем реальный ID. Если юзер не залогинен, возвращаем пустую строку или обрабатываем это на уровне UI
        return currentUser?.uid ?? ""
    }


    // MARK: - Auth Actions

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {

                completion(.failure(error))
                return
            }
            self?.currentUser = result?.user
            completion(.success(()))
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {


        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in

            if let error = error {

                completion(.failure(error))
                return
            }

            self?.currentUser = result?.user
            completion(.success(()))

        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {

            print("AuthService: Sign out error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let user = currentUser else {
            
            let error = NSError(domain: "AuthService", code: 401, userInfo: ["NSLocalizedDescriptionKey": "No user logged in"])
            
            completion(.failure(error))
            print("AuthService: \(error.localizedDescription)")
            return
        }
        
        user.delete { (error) in
            
            if let error = error {
                
                print(error.localizedDescription)
                completion(.failure(error))
            } else {
                print("AuthService: account was deleted succesfull")
                completion(.success(()))
                
            }
        }
    }
 
    // MARK: - Setup

    private func setupAuthStateListener() {

        authStateHandle = Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            self?.currentUser = user
            self?.onAuthStateChanged?(user)
            print("AuthService: User state changed. Logged in: \(user != nil)")
        })
    }

    deinit {
        if let handle = authStateHandle {

            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
