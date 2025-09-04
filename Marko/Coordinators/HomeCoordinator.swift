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
        
        repo.fetchTeachers { result in
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let teachers):
                print(teachers.first?.name ?? "None")
            
            }
            
        }
        
        let teacherVC = TeacherListVC()
        teacherVC.title = "Marko school"
        navigation.pushViewController(teacherVC, animated: false)
        
    }
}
