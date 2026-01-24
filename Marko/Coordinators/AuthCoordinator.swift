//
//  AuthCoordinator.swift
//  Marko
//
//  Created by Ivan on 18.01.2026.
//

import UIKit

class AuthCoordinator: Coordinator {
    
    var navigation: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    var didFinish: (() -> Void)?
    
    init(navController: UINavigationController) {
        self.navigation = navController
    }
    
    
    func start() {
        
        let vm = AuthViewModel()
        let vc = LoginVC(vm: vm)
        
        // Когда во ViewModel случается успех, мы дергаем финиш координатора
        vm.didAuthSuccess = { [weak self] in
            
            self?.didFinish?()
        }
        
        // В Auth флоу мы обычно скрываем Navigation Bar или делаем его прозрачным
        navigation.navigationBar.prefersLargeTitles = true
        navigation.setViewControllers([vc], animated: true)
    }
}
