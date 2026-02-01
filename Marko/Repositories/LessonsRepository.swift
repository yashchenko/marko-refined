//
//  LessonRepository.swift
//  Marko
//
//  Created by Ivan on 31.01.2026.
//
//

import Foundation
import FirebaseFirestore

class LessonsRepository {
    
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    
    // должна совпадать с названием коллекции в firebase
    private let collectionName = "lessons"
    
    // MARK: - Public methods
    
    func fetchMyLessons(userId: String, completion: @escaping (Result<[Lesson], Error>) -> Void ) {
        print("📚 LessonsRepository: Fetching lessons for student: \(userId)")
        
        // запрос к firestore
        db.collection(collectionName)
            .whereField("studentId", isEqualTo: userId)
            .order(by: "startTime", descending: false)
            .getDocuments { query, error in
                if let error = error {
                    
                    print("everything bad")
                    completion (.failure(error))
                    return
                }
                
                // querySnapshot.documents — это массив найденных документов, если пусто - студент не записался пока ни на один урок
                guard let documents = query?.documents else {
                    
                    print("no lessons found for student \(userId)")
                    completion (.success([]))
                    return
                }
                
                print("📦 LessonsRepository: Found \(documents.count) raw documents")

                
                let lessons = documents.compactMap { doc -> Lesson? in
                    
                    let documentID = doc.documentID
                    let data = doc.data()
                    
                    guard let lesson = Lesson(id: documentID, data: data) else {
                        print("⚠️ LessonsRepository: Failed to parse document \(documentID)")
                        return nil
                    }
                    
                    return lesson
                    
            }
                print("✅ LessonsRepository: Successfully parsed \(lessons.count) lessons")
                
                completion (.success(lessons))
        }
    }
}
 
//    // ========================================
//    // MARK: - Future Methods (для расширения)
//    // ========================================
//
//    // TODO: Метод для фильтрации только предстоящих уроков
//    // func fetchUpcomingLessons(userId: String, completion: ...)
//
//    // TODO: Метод для получения истории уроков
//    // func fetchCompletedLessons(userId: String, completion: ...)
//
//    // TODO: Метод для отмены урока
//    // func cancelLesson(lessonId: String, completion: ...)
//}
