//
//  AuthViewModel.swift
//  Marko
//
//  Created by Ivan on 18.01.2026.
//

import Foundation

class AuthViewModel {
    
    // MARK: - Inputs
    var email: String = ""
    var password: String = ""
    
    // MARK: - Outputs (Closures for UI updates)_
    var didLoadingStateChanged: ((Bool) -> Void)? // spinner
    var didErrorOccured: ((String) -> Void)? // error message for user
    var didAuthSuccess: (() -> Void)?
    
    private let authService = AuthService.shared
    
    // MARK: - Actions
    func handleLogin() {
        guard validateInput() else { return }
        
        didLoadingStateChanged?(true)
        
        authService.signIn(email: email, password: password) { [weak self] result in
            
            self?.didLoadingStateChanged?(false)
            
            switch result {
            case .success():
                self?.didAuthSuccess?()
                
            case .failure(let error):
                self?.didErrorOccured?(error.localizedDescription)
            
            }
        }
    }
    
    func handleRegister() {
        
        guard validateInput() else { return }
        
        didLoadingStateChanged?(true)
        
        authService.signUp(email: email, password: password) { [weak self] result in
            
            self?.didLoadingStateChanged?(false)
            
            switch result {
            case .success:
                self?.didAuthSuccess?()
                
            case .failure(let error):
                self?.didErrorOccured?("error sign up: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Validation
    
    private func validateInput() -> Bool {
        
        if email.isEmpty || password.isEmpty {
            didErrorOccured?("please fill in all fields")
            return false
        }
        
        if password.count < 6 {
            
            didErrorOccured?("Password must be at least 6 characters")
            return false
        }
        
        return true
        
    }
}
