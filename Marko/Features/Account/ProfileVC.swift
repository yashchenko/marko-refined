//
//  ProfileVC.swift
//  Marko
//
//  Created by Ivan on 25.03.2026.
//

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
            
            self.usingAlert()
//            self.present(self.termsVC, animated: true)
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
    
    func usingAlert() {
        
        let didCancel: (() -> ()) = {
            
            print("Profile VC: User did tap cancel on Refund alert")
        }
        
        let alert = CustomAlertVC(title: "Wanna refund", message: "Are u sure?", confirm: "OK", cancel: "No, I won't", didCancel: self.vm.refundmMoney, didOK: didCancel)
        
        present(alert, animated: false)
        
    }
    
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
