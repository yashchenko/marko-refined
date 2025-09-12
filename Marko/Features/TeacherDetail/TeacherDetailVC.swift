//
//  TeacherDetailVC.swift
//  Marko
//
//  Created by Ivan on 13.09.2025.
//

import UIKit

class TeacherDetailVC: UIViewController {
    
    private let vm: TeacherDetailVM
    
    init(vm: TeacherDetailVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = vm.teacher.name
    }
    
    
    
}
