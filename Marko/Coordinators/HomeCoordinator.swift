//  HomeCoordinator.swift
//  Marko
//
//  Created by Ivan on 28.08.2025.

import UIKit

class HomeCoordinator: Coordinator {
    
    var navigation: UINavigationController
    var childCoordinators = [Coordinator]()
    
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
        
        
        
        
        
        //navigation.setViewControllers([homeVC], animated: true)
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
        
        
        
    }
    
}
//
//
//class HomeCoordinator: Coordinator {
//
//    var navigation: UINavigationController
//    var childCoordinators = [Coordinator]()
//
//    init(nav: UINavigationController) {
//        self.navigation = nav
//    }
//
//    func start() {
//        let repo = TeacherRepository()
//        let homeVM = HomeViewModel(teacherDatabase: repo)
//        let homeVC = HomeVC(vm: homeVM)
//
//
//        homeVM.didSelaectTeacher = { [weak self] teacher in
//
//            self?.showTeacherDetail(for: teacher)
//
//        }
//
//
//        homeVM.didSignInTapped = { [weak self] in
//
//            self?.showLoginModal()
//
//        }
//
//        // ========================================
//        // MAR-174: Добавлена навигация к My Lessons
//        // ========================================
//        homeVM.didMyLessonsTapped = { [weak self] in
//
//            self?.showMyLessons()
//        }
//
//
//
//
//
//        //navigation.setViewControllers([homeVC], animated: true)
//        navigation.setViewControllers([homeVC], animated: true  )
//
//    }
//
//    func showTeacherDetail(for teacher: Teacher) {
//        let timeSlotRepo = TimeSlotRepository()
//        let teacherDetailVM = TeacherDetailVM(teacher: teacher, timeSlotRepo: timeSlotRepo)
//        let teacherDetailVC = TeacherDetailVC(vm: teacherDetailVM)
//
//        teacherDetailVM.didAuthNeeded = { [weak self] in
//
//            self?.showLoginModal()
//        }
//
//        navigation.pushViewController(teacherDetailVC, animated: true)
//    }
//
//    func showLoginModal() {
//
//        let authNav = UINavigationController()
//        let authCoordinator = AuthCoordinator(navController: authNav)
//
//        // Код, который должен выполниться, когда юзер успешно войдет
//        authCoordinator.didFinish = { [weak self, weak authNav] in
//
//            authNav?.dismiss(animated: true)
//            self?.childCoordinators.removeAll { $0 === authCoordinator }
//        }
//
//        // удержание в памяти
//        childCoordinators.append(authCoordinator)
//
//        // показ экрана
//        authCoordinator.start()
//
//        navigation.present(authNav, animated: true)
//
//    }
//
//    // ========================================
//    // MAR-174: Новый метод навигации
//    // ========================================
//
//    /// Показывает экран "My Lessons"
//    private func showMyLessons() {
//
//        print("🎓 HomeCoordinator: Navigating to My Lessons")
//
//        // Создаём ViewModel и ViewController
//        let lessonsVM = MyLessonsViewModel()
//        let lessonsVC = MyLessonsVC(viewModel: lessonsVM)
//
//        // Push навигация
//        navigation.pushViewController(lessonsVC, animated: true)
//    }
//
//}
