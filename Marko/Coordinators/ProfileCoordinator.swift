//
//  ProfileCoordinator.swift
//  Marko
//
//  Created by Ivan on 04.05.2026.
//

import UIKit

class ProfileCoordinator: Coordinator {
    
    var navigation: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    init(nav: UINavigationController) {
        self.navigation = nav
    }
    
    func start() {
        let profileVM = ProfileVM()
        let profileVC = ProfileVC(vm: profileVM)
        
        navigation.pushViewController(profileVC, animated: true)
    }
}
