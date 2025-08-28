//
//  MainCoordinator.swift
//  Marko
//
//  Created by Ivan on 27.08.2025.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigation: UINavigationController
    var window: UIWindow?
    
    init(window: UIWindow) {
        self.navigation = UINavigationController()
        self.window = window
    }
    
    func start() {
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        
        let homeCoordinator = HomeCoordinator(nav: navigation)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
}
