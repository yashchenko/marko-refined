//
//  CoordinatorProtocol.swift
//  Marko
//
//  Created by Ivan on 27.08.2025.
//

import UIKit

protocol Coordinator {
    var navigation: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
}
