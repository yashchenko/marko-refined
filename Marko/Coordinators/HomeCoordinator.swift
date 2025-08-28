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
        let teacherVC = TeacherListVC()
        teacherVC.title = "Marko school"
        navigation.pushViewController(teacherVC, animated: false)
    }
}
