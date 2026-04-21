//
//  ProfileVC.swift
//  Marko
//
//  Created by Ivan on 25.03.2026.
//

//title отображается только если экран находится внутри UINavigationController. Судя по скриншоту — navigation bar вообще нет, значит твой координатор показывает ProfileVC без него.
//Скинь координатор — посмотрю как он презентует этот экран, там и исправим.


import UIKit
import SnapKit

class ProfileVC: UIViewController {

    // MARK: - Properties

    var vm: ProfileVM
    let termsVC = TermsOfServiceVC()
    let privacyPolicyVC = PrivacyPolicyVC()
    
    
    lazy var stackOfButton: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            termsButton,
            privacyPolicyButton,
            deleteButton
        ])
        
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    

    lazy var deleteButton: UIButton = {

        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitle("Delete account", for: .normal)
        button.addAction(UIAction {_ in
            self.vm.deleteAccount()

        }, for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var termsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.setTitle("Terms of service", for: .normal)
        button.addAction(UIAction { _ in
            self.present(self.termsVC, animated: true)
        }, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var privacyPolicyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemIndigo
        button.setTitle("Privacy policy", for: .normal)
        button.addAction(UIAction { _ in
            self.present(self.privacyPolicyVC, animated: true)
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        
    
    
    // pop-up alert (maybe custom alert) - ваш токен протух, для удаления акаунта разлогиньтесь и снова залогиньтесь тогда удаление станет доступно

    init(vm: ProfileVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        title = "Profile"
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

        view.addSubviews(views: [
            
//            deleteButton,
//            termsButton,
//            privacyPolicyButton
            
            stackOfButton

        ])

        view.backgroundColor = .systemBackground
        
        stackOfButton.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(view.snp.centerY)
            make.bottom.equalTo(view.snp.bottom)
        }

//        deleteButton.snp.makeConstraints { (make) in
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//            make.centerX.equalToSuperview()
//        }
//
//        termsButton.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//        }
//
//        privacyPolicyButton.snp.makeConstraints { make in
//            make.top.equalTo(termsButton.snp.bottom).offset(20)
//
//        }
        
    }
}












//import UIKit
//import SnapKit
//import SafariServices // Нужно для открытия веб-ссылок
//
//class ProfileVC: UIViewController {
//
//    // MARK: - Properties
//    var vm: ProfileVM
//
//    // MARK: - UI Elements
//
//    // 1. Почта пользователя (из Acceptance Criteria)
//    private lazy var emailLabel: UILabel = {
//        let label = UILabel()
//        label.text = "" // Берем из ViewModel
//        label.font = .systemFont(ofSize: 20, weight: .semibold)
//        label.textAlignment = .center
//        return label
//    }()
//
//    // Твои заглушки (оставляем, если хочешь)
//    var bonusBalance: UILabel = {
//        let balance = UILabel()
//        balance.text = "Bonus balance: 0 Coins"
//        balance.font = .systemFont(ofSize: 16, weight: .medium)
//        balance.textColor = .systemOrange
//        return balance
//    }()
//
//    // 2. Кнопка логаута (из Acceptance Criteria)
//    lazy var signOutButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Sign Out", for: .normal)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 12
//
//        button.addAction(UIAction { [weak self] _ in
//            self?.vm.signOut()
//        }, for: .touchUpInside)
//        return button
//    }()
//
//    // 3. Документы для Apple (из Acceptance Criteria)
//    lazy var privacyButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Privacy Policy", for: .normal)
//        button.setTitleColor(.systemBlue, for: .normal)
//        button.addAction(UIAction { [weak self] _ in
//            self?.openWebLink("https://apple.com") // Заглушка
//        }, for: .touchUpInside)
//        return button
//    }()
//
//    // 4. Правильная кнопка удаления (UX best practices)
//    lazy var deleteButton: UIButton = {
//        let button = UIButton(type: .system)
//        // Делаем ее просто текстом, без красного фона!
//        button.setTitle("Delete account", for: .normal)
//        button.setTitleColor(.systemGray, for: .normal) // Серая и незаметная
//        button.titleLabel?.font = .systemFont(ofSize: 14)
//
//        button.addAction(UIAction { [weak self] _ in
//            self?.showDeleteAlert() // Вызываем Alert, а не сразу удаляем!
//        }, for: .touchUpInside)
//        return button
//    }()
//
//    // MARK: - Init
//
//    init(vm: ProfileVM) {
//        self.vm = vm
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
//        setupUI()
//    }
//
//    // MARK: - Setup
//
//    func setupUI() {
//        title = "Profile"
//        view.backgroundColor = .systemBackground // .systemGray3 слишком темный для фона профиля
//
//        // Используем StackView, чтобы не писать миллион констрейнтов
//        let stack = UIStackView(arrangedSubviews: [
//            emailLabel,
//            bonusBalance,
//            signOutButton,
//            privacyButton
//        ])
//        stack.axis = .vertical
//        stack.spacing = 24
//        stack.alignment = .center
//
//        view.addSubviews(views: [stack, deleteButton])
//
//        // Констрейнты для стека
//        stack.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
//            make.centerX.equalToSuperview()
//        }
//
//        signOutButton.snp.makeConstraints { make in
//            make.width.equalTo(200)
//            make.height.equalTo(50)
//        }
//
//        // Прячем удаление в самый подвал экрана
//        deleteButton.snp.makeConstraints { make in
//            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
//            make.centerX.equalToSuperview()
//        }
//    }
//
//    // MARK: - Actions & Helpers
//
//    // Тот самый Alert из Acceptance Criteria
//    private func showDeleteAlert() {
//        let alert = UIAlertController(
//            title: "Delete Account",
//            message: "Are you sure? This action cannot be undone and you will lose all data.",
//            preferredStyle: .alert
//        )
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
//
//        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
//            self?.vm.deleteAccount()
//        }
//
//        alert.addAction(cancel)
//        alert.addAction(delete)
//        present(alert, animated: true)
//    }
//
//    // Метод для открытия Политики Конфиденциальности
//    private func openWebLink(_ urlString: String) {
//        guard let url = URL(string: urlString) else { return }
//        let safariVC = SFSafariViewController(url: url)
//        present(safariVC, animated: true)
//    }
//}
