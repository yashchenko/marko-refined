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
    
    var didProfileTapped: (() -> ())?
    
    // MARK: - Init
    
    init(lessonRepo: LessonsRepository = LessonsRepository()) {
        self.lessonsRepo = lessonRepo
    }
    
    // MARK: - Public Methods
    
    func loadLessons() {
        let currentUserId = AuthService.shared.currentUserId
        
        guard !currentUserId.isEmpty else {
            print("⚠️ LessonsVM: User not logged in")
            didErrorOccur?("Please log in to view your lessons")
            return
        }
        
        print("📚 LessonsVM: Starting loading lessons...")
        
        // Instant Loading from Core Data
        
        let cachedLessons = CoreDataManager.shared.fetchCachedLessons()
        
        if !cachedLessons.isEmpty {
            self.lessonsArray = cachedLessons
            self.didLessonsUpdate?()
            print("⚡️ LessonsVM: The screen is instantly rendered from the cache.")
        } else {
            // Spin the loading spinner ONLY if the cache is empty
            isLoading = true
            didLoadingStateChange?(true)
        }
        
        
        // STEP 2: Background Request to Firebase
        
        lessonsRepo.fetchMyLessons(userId: currentUserId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.didLoadingStateChange?(false)
                
                switch result {
                
                case .success(let myFetchedLessons):
                    print("✅ LessonsVM: Fresh data received from Firebase (\(myFetchedLessons.count) шт.)")
                    
                    // Обновляем UI свежими данными
                    self.lessonsArray = myFetchedLessons
                    self.didLessonsUpdate?()
                    
                    // ШАГ 3: Перезаписываем локальный кэш свежими данными (в фоне)
                    CoreDataManager.shared.saveLessons(domainLessons: myFetchedLessons)
                    
                case .failure(let error):
                    print("❌ LessonsVM: Internet error - \(error.localizedDescription)")
                    
                    // ШАГ 4: Обработка оффлайна
                    if self.lessonsArray.isEmpty {
                        // Если инета нет, и кэш пуст — показываем реальную ошибку
                        self.didErrorOccur?("No internet connection and no offline data. Please try again later.")
                    } else {
                        // Кэш есть, юзер видит старые уроки. Мы просто ничего не делаем (можно показать тихий Toast "Offline Mode", но для MVP сойдет и так)
                        print("📡 We work in offline mode")
                    }
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

