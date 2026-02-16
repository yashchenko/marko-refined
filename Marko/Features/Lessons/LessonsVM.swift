//
//  LessonsVM.swift
//  Marko
//
//  Created by Ivan on 04.02.2026.
//

import Foundation

class LessonsVM {
    
    // MARK: - Properties
    
    let lessonsRepo: LessonsRepository
    
    private(set) var lessonsArray = Array<Lesson>()
    
    private(set) var isLoading: Bool = false
    
    // MARK: - Closures for UI
    
    var didLessonsUpdate: (() -> Void)?
    
    var didLoadingStateChange: ((Bool) -> Void)?
    
    var didErrorOccur: ((String) -> Void)?
    
    // MARK: - Init
    
    init(lessonRepo: LessonsRepository = LessonsRepository()) {
        self.lessonsRepo = lessonRepo
    }
    
    // MARK: - Public Methods
    
    func loadLessons() {
        let currentUserId = AuthService.shared.currentUserId
        
        guard !currentUserId.isEmpty else {
            print("⚠️ MyLessonsVM: User not logged in")
            didErrorOccur?("Please log in to view your lessons")
            return
        }
        
        isLoading = true
        didLoadingStateChange?(true)
        
        print("📚 MyLessonsVM: Fetching lessons for user '\(currentUserId)'")

        lessonsRepo.fetchMyLessons(userId: currentUserId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.didLoadingStateChange?(false)
                
                switch result {
                
                case .success(let myFetchedLessons):
                    print("✅ LessonsVM: Loaded: \(myFetchedLessons.count) lessons")
                    self.lessonsArray = myFetchedLessons
                    self.didLessonsUpdate?()
            
                case .failure(let error):
                    print("❌ MyLessonsVM: Failed to load lessons - \(error.localizedDescription)")
                    self.lessonsArray = []
                    self.didLessonsUpdate?()
                    self.didErrorOccur?("Failed to load lessons. Please try again.")
                }
            }
        }
    }
    
    var numberOfLessons: Int {
        return lessonsArray.count
        
    }
    
    func lesson(the index: Int) -> Lesson? {
        guard index >= 0 && index < lessonsArray.count else { return nil }
        return lessonsArray[index]
    }
    
    
    var hasLessons: Bool {
        
        return !lessonsArray.isEmpty
    }
}

