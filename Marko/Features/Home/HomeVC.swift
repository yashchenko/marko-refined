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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    
    init(vm: HomeViewModel) {
        self.homeViewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        
        homeViewModel.closureOutlet = { [weak self] in
            guard let self = self else { return }
            
            print("Home vc screen receive the siglal from ether")
            
            self.collectionView.reloadData()
            
        }
        
        homeViewModel.fetchTeachers()
        view.backgroundColor = .systemGray6
        
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.register(TeacherCollectionViewCell.self, forCellWithReuseIdentifier: TeacherCollectionViewCell.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
}




extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        homeViewModel.teachersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeacherCollectionViewCell.reuseIdentifier, for: indexPath) as? TeacherCollectionViewCell else { return UICollectionViewCell() }
        let teacher = homeViewModel.teachersArray[indexPath.item]
        cell.configure(with: teacher)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // We want our cells to have a 20-point margin on the left and right& So, the total padding is 40 points.
        let padding: CGFloat = 40
        let availableWidth = view.frame.width - padding
        
        // We return a CGSize object with our desired width and a fixed height.
        return CGSize(width: availableWidth, height: 450)
    }
    
    
    // This function defines the spacing for the entire section. Think of it as the padding for the top, left, bottom, and right of the whole list.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       
        // We want 24 points of space at the top of the list and at the bottom. We don't need left/right padding here because the cell's size calculation already handles that.
        return UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
    
    // This function defines the vertical spacing between each cell.

    // This function defines the vertical spacing BETWEEN each cell.
    // The name must be EXACTLY "minimumLineSpacingForSectionAt".
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //                                                                                                 ^
        //                                                                                                 |
        //                                                                         THIS IS THE FIX: The word "Line" was added here.
        
        // We want 24 points of vertical space between each teacher card.
        return 24
    }
    
}
