//
//  AuthVC.swift
//  Marko
//
//  Created by Ivan on 19.01.2026.
//

import UIKit
import SnapKit

class LoginVC: UIViewController {
    
    private let vm: AuthViewModel
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome To Marko"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailField: UITextField = {
        let email = UITextField()
        email.placeholder = "Email"
        email.borderStyle = .roundedRect
        email.autocapitalizationType = .none
        email.keyboardType = .emailAddress
        email.translatesAutoresizingMaskIntoConstraints = false
        return email
    }()
    
    private let passwordField: UITextField = {
        let passw = UITextField()
        passw.translatesAutoresizingMaskIntoConstraints = false
        passw.placeholder = "Password"
        passw.borderStyle = .roundedRect
        passw.isSecureTextEntry = true
        return passw
    }()
    
    private let loginButton: UIButton = {
        let login = UIButton(type: .system)
        login.setTitle("Log In", for: .normal)
        login.backgroundColor = .systemBlue
        login.setTitleColor(.white, for: .normal)
        login.layer.cornerRadius = 8
        login.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        login.translatesAutoresizingMaskIntoConstraints = false
        return login
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(vm: AuthViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
        setupActions()
    }

    private func setupUI() {
        
        let stack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16
            stack.distribution = .fillEqually
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        view.addSubview(titleLabel)
        view.addSubview(stack)
        view.addSubview(activityIndicator)
        
        stack.addArrangedSubviews(view: [
        
            emailField,
            passwordField,
            loginButton,
            registerButton
        
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.centerX.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        // высота кнопок, полей для ввода
        emailField.snp.makeConstraints { make in make.height.equalTo(50) }
        passwordField.snp.makeConstraints { maker in maker.height.equalTo(50) }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        
        let loginAction = UIAction { [weak self] _ in
            
            self?.updateVM()
            self?.vm.handleLogin()
            
        }

        loginButton.addAction(loginAction, for: .touchUpInside)
        
        let signUpAction = UIAction { [weak self] _ in
            
            self?.updateVM()
            self?.vm.handleRegister()
        }
        
        self.registerButton.addAction(signUpAction, for: .touchUpInside)
    }
    
    private func updateVM() {
        vm.email = emailField.text ?? ""
        vm.password = passwordField.text ?? ""
    }
    
    private func bindViewModel() {
        vm.didLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.view.isUserInteractionEnabled = false
                } else{
                    self?.activityIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
            }
        }
        
        vm.didErrorOccured = { [weak self] errorMsg in
            DispatchQueue.main.async {
                self?.showAlert(message: errorMsg)
            }
        }
    }
    
    private func showAlert(message: String) {
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
    }
}
