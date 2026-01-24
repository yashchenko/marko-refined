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
        
        //navigation.setViewControllers([homeVC], animated: true)
        navigation.pushViewController(homeVC, animated: false)
        
    }
    
    func showTeacherDetail(for teacher: Teacher) {
        let timeSlotRepo = TimeSlotRepository()
        let teacherDetailVM = TeacherDetailVM(teacher: teacher, timeSlotRepo: timeSlotRepo)
        let teacherDetailVC = TeacherDetailVC(vm: teacherDetailVM)
        navigation.pushViewController(teacherDetailVC, animated: true)
    }
}
