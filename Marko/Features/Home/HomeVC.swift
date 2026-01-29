//
//  HomeVC.swift
//  Marko
//
//  Created by Ivan on 05.09.2025.
//
//



import UIKit
import Firebase
import SnapKit

class HomeVC: UIViewController {
    
    var vm: HomeViewModel
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // [MAR-171] Кнопка для залогиненного пользователя
    lazy var lessonsButton: UIButton = {
       
        let button = UIButton(type: .system)
        button.setTitle("My Lessons", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 15
        
        // some padding inside the button
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 9, right: 16)
        
        let action = UIAction { [weak self] _ in
            
            self?.vm.myLessonsTapped()
        }
        
        button.addAction(action, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    // [MAR-171] Кнопка для гостя
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 15
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false

        // [MAR-171] Action: Используем твой метод signInTappaed()
        let action = UIAction { [weak self] _ in
            self?.vm.signInTappaed()
        }
        button.addAction(action, for: .touchUpInside)

        return button
    }()


    init(vm: HomeViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavBar()
        setupConstraints()
        
        // [MAR-171] Подписка на статус авторизации
        AuthService.shared.onAuthStateChanged = { [weak self] user in
            
            DispatchQueue.main.async {
                self?.updateNavBar(for: user)
            }
        }
        
        vm.didFetchTeachers = { [weak self] in
            guard let self = self else { return }
            
            print("Home vc screen receive the siglal from ether")
            
            self.collectionView.reloadData()
        }
        
        vm.fetchTeachers()
        view.backgroundColor = .systemGray6
        
        updateNavBar(for: AuthService.shared.currentUser)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.register(TeacherCollectionViewCell.self, forCellWithReuseIdentifier: TeacherCollectionViewCell.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        // [DEV ONLY] Добавляем долгий тап на кнопку уроков для выхода
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleSignOut(gesture: )))
        lessonsButton.addGestureRecognizer(longPress)
        
    }
    
    private func setupNavBar() {
        
        let titleLabel = UILabel()
        titleLabel.text = "Marko School"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        
        // [MAR-171] Убрали старую кнопку профиля. Оставили только title.
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func updateNavBar(for user: FirebaseAuth.User?) {
        
        if user != nil {
            let lessonBarButton = UIBarButtonItem(customView: lessonsButton)
            navigationItem.rightBarButtonItem = lessonBarButton
        } else {
            
            let signInBarButton = UIBarButtonItem(customView: signInButton)
            navigationItem.rightBarButtonItem = signInBarButton
        }
    }
    
    
    private func setupConstraints() {
        
        collectionView.snp.makeConstraints({ make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        })
    }
    
    // [DEV ONLY] Временный выход для тестирования
    @objc private func handleSignOut(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            AuthService.shared.signOut()
            
            let alert = UIAlertController(title: "Dev Mode", message: "Signed Out Succesfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
    }
}


extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.teachersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeacherCollectionViewCell.reuseIdentifier, for: indexPath) as? TeacherCollectionViewCell else { return UICollectionViewCell() }
        let teacher = vm.teachersArray[indexPath.item]
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTeacher = vm.teachersArray[indexPath.item]
        vm.didSelaectTeacher?(selectedTeacher)
    }
}
