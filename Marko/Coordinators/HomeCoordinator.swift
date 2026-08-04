//  HomeCoordinator.swift
//  Marko
//
//  Created by Ivan on 28.08.2025.

import UIKit

class HomeCoordinator: Coordinator {
    
    var navigation: UINavigationController
    var childCoordinators = [Coordinator]()
    private var activeChatRepo: ChatRepo?
    
    init(nav: UINavigationController) {
        self.navigation = nav
    }
    
    func start() {
        let repo = TeacherRepository()
        let homeVM = HomeViewModel(teacherDatabase: repo)
        let homeVC = HomeVC(vm: homeVM)
        
            
        homeVM.didSelaectTeacher = { [weak self] teacher in
            
            self?.showTeacherDetail(for: teacher)
        }
        
        homeVM.didSignInTapped = { [weak self] in
            
            self?.showLoginModal()
        }
        
        homeVM.didMyLessonsTapped = { [weak self] in
            
            self?.showMyLessons()
        }
   
        navigation.setViewControllers([homeVC], animated: true  )
        
    }
    
    func showTeacherDetail(for teacher: Teacher) {
        let timeSlotRepo = TimeSlotRepository()
        let teacherDetailVM = TeacherDetailVM(teacher: teacher, timeSlotRepo: timeSlotRepo)
        let teacherDetailVC = TeacherDetailVC(vm: teacherDetailVM)
        
        teacherDetailVM.didAuthNeeded = { [weak self] in
            
            self?.showLoginModal()
        }
        
        navigation.pushViewController(teacherDetailVC, animated: true)
        
    }
    
    func showLoginModal() {
        
        let authNav = UINavigationController()
        let authCoordinator = AuthCoordinator(navController: authNav)
        
        // Код, который должен выполниться, когда юзер успешно войдет
        authCoordinator.didFinish = { [weak self, weak authNav] in
            
            authNav?.dismiss(animated: true)
            self?.childCoordinators.removeAll { $0 === authCoordinator }
        }
        
        // удержание в памяти
        childCoordinators.append(authCoordinator)
        
        // показ экрана
        authCoordinator.start()
        
        navigation.present(authNav, animated: true)
        
    }
    
    func showMyLessons() {
        
        print("🎓 HomeCoordinator: Navigating to My Lessons")
        
        let lessonRepo = LessonsRepository()
        let myLessonsVM = LessonsVM(lessonRepo: lessonRepo)
        let myLessonsVC = LessonsVC(vm: myLessonsVM)
    
        navigation.pushViewController(myLessonsVC, animated: true)
        
        myLessonsVM.didProfileTapped = { [weak self] in
            
            guard let self = self else { return }
            
            let profileCoordinator = ProfileCoordinator(nav: self.navigation)
            self.childCoordinators.append(profileCoordinator)
            profileCoordinator.start()
          
        }
        
        myLessonsVM.routeToNavigator = { [weak self] id, name in
            
            self?.showMessenger(id: id, name: name)
        }
    }
    
    func showMessenger(id: String, name: String) {
        let messenferRepo = ChatRepo()
        self.activeChatRepo = messenferRepo
        
        let dummyTeacher = Teacher(id: id, name: name, headline: "", profileImageURL: "", rating: 0, reviewCount: 0, hourlyRate: 0, fullDescription: "", contactURL: "", subject: "")
        
        messenferRepo.getOrCreateChat(teacher: dummyTeacher) { result in
            
            DispatchQueue.main.async {
                
                switch result {
                
                case .success(let chat):
                    
                    let chatVM = ChatVM(chat: chat)
                    let chatVC = ChatVC(chatVM: chatVM)
                    
                    self.navigation.pushViewController(chatVC, animated: true)
                    //self.navigation.present(chatVC, animated: true)
                
                case .failure(let error):
                    
                    print(error.localizedDescription)
                
                }
                self.activeChatRepo = nil
            }
            
        }
    
    }
}
