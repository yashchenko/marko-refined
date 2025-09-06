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
        navigation.pushViewController(homeVC, animated: false)
    }
}
