//
//  User.swift
//  Marko
//
//  Created by Ivan on 01.09.2025.
//

import Foundation

struct User: Codable {
    let id: String                 // unique UUID from backend
    let email: String?
    let name: String?
    let secondName: String?
    let initials: String
    let avatarURL: URL?
    let createdAt: Date
    
    
    var displayInitials: String {
        if let name = name, !name.isEmpty {
            let firstInitial = name.first.map { String($0) } ?? ""
            let lastInitial = secondName?.first.map { String($0) } ?? ""
            return (firstInitial + lastInitial).uppercased()
        }
        
        return initials
    }
}
