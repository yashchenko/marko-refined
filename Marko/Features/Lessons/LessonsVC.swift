//
//  LessonsVC.swift
//  Marko
//
//  Created by Ivan on 10.02.2026.
//

import UIKit
import SnapKit

class LessonsVC: UIViewController {
    
    // MARK: - Properties
    
    private let vm: LessonsVM
    
    // MARK: - UI
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self

        // register cell
        collectionView.register(LessonCell.self, forCellWithReuseIdentifier: LessonCell.reuseIdentifier)
        
        // pull-to-refresh
        collectionView.refreshControl = refreshControl
        
        return collectionView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        return refresh
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // empty state (when no buyed lesson)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No lessons yet"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    lazy private var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Profile", for: .normal)
        button.backgroundColor = .systemGray3
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 15
        button.addAction(UIAction { _ in
            
            self.vm.didProfileTapped?()
            
        }, for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Init
    
    init(vm: LessonsVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        bindViewModel()
        setupActions()
        setupNavBar()
        
        vm.loadLessons()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        title = "My Lessons"
        view.backgroundColor = .systemBackground
        
        view.addSubviews(views: [
        
            collectionView,
            activityIndicator
        
        ])
    }
    
    
    private func setupNavBar() {
        
        let button = UIBarButtonItem(customView: profileButton)
        navigationItem.rightBarButtonItem = button
        
    }
    
    private func setupConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func updateUI() {
        
        if vm.hasLessons {
            
            collectionView.backgroundView = nil

            
        } else {
            
            //collectionView.backgroundView = emptyStateLabel
            
            let emptyState = EmptyState()
            
            collectionView.backgroundView = emptyState
            
        //    view.addSubview(emptyState)
            
        
            
            emptyState.configure(image: "no_date", mainLabel: "No lessons yet", subtitleLabel: "")
            
        }
        
        collectionView.reloadData()

    }
    
    private func bindViewModel() {
        
        vm.didLessonsUpdate = { [weak self] in
            
            self?.updateUI()
            
        }
        
        vm.didLoadingStateChange = { [weak self] isLoading in
            
            if isLoading {
                
                if self?.vm.lessonsArray.isEmpty == true {
                    
                    self?.activityIndicator.startAnimating()
                }
                
            } else {
                
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
            }
        }
        
        vm.didErrorOccur = { [weak self] error in
            
            self?.showErrorAlert(message: error)
            
            
        }
    }
    
    private func showErrorAlert(message: String) {
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        
        // pull-to-refresh action
        refreshControl.addTarget(self, action: #selector(handleAction), for: .valueChanged)
        
    }
    
    @objc func handleAction() {
        vm.loadLessons()
    }
}

// MARK: - UICollectionViewDataSource

extension LessonsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.numberOfLessons
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LessonCell.reuseIdentifier, for: indexPath) as? LessonCell else { return UICollectionViewCell() }
        
        if let lesson = vm.lesson(the: indexPath.item) {
            cell.configure(lesson: lesson)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LessonsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Ширина ячейки = ширина экрана - отступы
        let padding: CGFloat = 32 // 16 справа и 16 слева
        let availableWidth = collectionView.frame.width - padding
        
        // Высота фиксированная (как в LessonCell)
        let height: CGFloat = 220
        
        return CGSize(width: availableWidth, height: height)
    }
    
}

// MARK: - UICollectionViewDelegate

extension LessonsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let lesson = vm.lesson(the: indexPath.item) else { return }
        
        // TODO: Навигация к деталям урока или Join Lesson

        print("Selected lesson: \(lesson.teacherName)")
        
        
        // TODO: MAR-175 add subject in Lesson
        // print("Selected lesson: \(lesson.teacherName) - \(lesson.subject)")

    }
}
