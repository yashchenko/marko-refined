//
//  TeacherRepository.swift
//  Marko
//
//  Created by Ivan on 02.09.2025.
//
//

import Foundation
import FirebaseFirestore

class TeacherRepository {
    
    private let db = Firestore.firestore()
    private let collectionName = "teachers"
    
    func fetchTeachers(completion: @escaping (Result<[Teacher], Error>) -> Void) {
        
        db.collection(collectionName).getDocuments { querySnaphot, error in
            if let error = error {
                print("error getting teacher documents: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnaphot?.documents else {
                print("no teacher documents found")
                completion(.success([]))
                return
            }
            
            let teachers = documents.compactMap { doc -> Teacher? in
                let data = doc.data()
                let id = doc.documentID
                
                guard
                    let name = data["name"] as? String,
                    let headline = data["headline"] as? String,
                    let profileImageURL = data["profileImageURL"] as? String,
                    let rating = data["rating"] as? Double,
                    let reviewCount = data["reviewCount"] as? Int,
                    let hourlyRate = data["hourlyRate"] as? Int,
                    let fullDescription = data["fullDescription"] as? String
                else {
                    print("warning! skipping document \(id) due to missing files")
                    return nil
                }
            
            let contactURL = data["contactURL"] as? String
            
                return Teacher(id: id, name: name, headline: headline, profileImageURL: profileImageURL, rating: rating, reviewCount: reviewCount, hourlyRate: hourlyRate, fullDescription: fullDescription, contactURL: contactURL)
                
            }
            
            print("successfully fetched and mapped \(teachers.count) teachers")
            completion(.success(teachers))
        }
    }
}
