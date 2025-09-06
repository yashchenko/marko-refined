//
//  HomeVC.swift
//  Marko
//
//  Created by Ivan on 05.09.2025.
//
//

import UIKit

class HomeVC: UIViewController {
    
    var homeViewModel: HomeViewModel
    
    
    init(vm: HomeViewModel) {
        self.homeViewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeViewModel.closureOutlet = { [weak self] in
            guard let self = self else { return }
            print("Home vc screen receive the siglal from ether")
            
            // here will be reload table
        }
        
        homeViewModel.fetchTeachers()
        
        view.backgroundColor = .systemGray6
        
    }
    
}

































//import UIKit
//
//class HomeViewController: UIViewController {
//
//    // MARK: - Properties
//
//    private let viewModel: HomeViewModel
//    
//    // MARK: - Initializer
//
//    init(viewModel: HomeViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground // A standard background color
//
//        // Bind the ViewModel's update handler to our UI update function
//        viewModel.onTeachersUpdated = { [weak self] in
//            print("ViewController: ViewModel told me teachers were updated!")
//            // In the next ticket, we'll reload a collection view here.
//        }
//
//        // Tell the ViewModel to start fetching the data
//        viewModel.fetchTeachers()
//    }
//}
