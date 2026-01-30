//
//  MainCoordinator.swift
//  Marko
//
//  Created by Ivan on 27.08.2025.
//

import UIKit
import  Firebase

class MainCoordinator: Coordinator {
    
    var navigation: UINavigationController
    var childCoordinators = [Coordinator]()
    var window: UIWindow?
    
    
    init(window: UIWindow) {
        
        self.window = window
        self.navigation = UINavigationController()
    }
    
    func start() {
        
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        
        showHomeFlow()
    }
    

//
//    private func showAuthFlow() {
//
//        let authCoordinator = AuthCoordinator(navController: navigation)
//        childCoordinators.append(authCoordinator)
//        authCoordinator.start()
//
//        // Обработка завершения логина (опционально, т.к. мы и так слушаем onAuthStateChanged)
//        authCoordinator.didFinish = {
//
//        // Ничего делать не надо, сработает onAuthStateChanged и переключит на Home
//
//        }
//
//    }
//
    private func showHomeFlow() {
        guard childCoordinators.isEmpty else { return }
        
        let homeCoordinator = HomeCoordinator(nav: navigation)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        
    }
}
