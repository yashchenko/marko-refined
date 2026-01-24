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
        
        // Подписываемся на изменения статуса авторизации
        AuthService.shared.onAuthStateChanged = { [weak self] user in
            
            DispatchQueue.main.async {
                self?.checkFlow(user: user)

            }
            
        }
        
        // Первичная проверка при запуске
        checkFlow(user: AuthService.shared.currentUser)
        
    }
    
    private func checkFlow(user: FirebaseAuth.User?) {
        
        // Очищаем старых координаторов, чтобы не плодить их
        childCoordinators.removeAll()
        
        if user != nil {
            
            showHomeFlow()
            
        } else {
            
            showAuthFlow()
        }
    }

    
    private func showAuthFlow() {
        
        let authCoordinator = AuthCoordinator(navController: navigation)
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
        
        // Обработка завершения логина (опционально, т.к. мы и так слушаем onAuthStateChanged)
        authCoordinator.didFinish = {
            
        // Ничего делать не надо, сработает onAuthStateChanged и переключит на Home
            
        }
        
    }
    
    private func showHomeFlow() {
        
        let homeCoordinator = HomeCoordinator(nav: navigation)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        
    }
    
}
