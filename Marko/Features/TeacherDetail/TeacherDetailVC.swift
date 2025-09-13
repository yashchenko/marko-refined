//
//  TeacherDetailVC.swift
//  Marko
//
//  Created by Ivan on 13.09.2025.
//

import UIKit

class TeacherDetailVC: UIViewController {
    
    private let vm: TeacherDetailVM
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

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
        
        
        view.addSubview(headlineLabel)
        
        headlineLabel.text = vm.teacher.headline
        
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Center the label horizontally in the view
            headlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Position it 150 points from the top of the safe area
            headlineLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            
            // Add left and right padding so it doesn't touch the edges
            headlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headlineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
