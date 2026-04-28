//
//  AlertVc.swift
//  Marko
//
//  Created by Ivan on 24.04.2026.
//

//import UIKit
//
//class AlertVc: UIViewController {
//    
//    
//    
//    
//}
//

import UIKit
import SnapKit

// MARK: - CustomAlertVC

final class CustomAlertVC: UIViewController {
    
    // MARK: - Callbacks
    
    var didConfirmTapped: (() -> ())?
    
    var didCancelTapped: (() -> ())?
    
    // MARK: - Properties
    
    private let shadowContainer = UIView()
    
    private let blurView: UIVisualEffectView = {
       
        let blur = UIBlurEffect(style: .systemMaterial)
        return UIVisualEffectView(effect: blur)
        
    }()
    
    private let titleLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let messageLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
 
    
    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    // MARK: - Data
    
    private let alertTitle: String
    private let alertMessage: String
    private let confirm: String
    private let cancel: String?
    
    // MARK: - Init
    
    init(title: String, message: String, confirm: String = "OK", cancel: String? = nil, didCancel: (() -> Void)? = nil, didOK: (() -> Void)? = nil) {
        self.alertTitle = title
        self.alertMessage = message
        self.confirm = confirm
        self.cancel = cancel
        self.didCancelTapped = didCancel
        self.didConfirmTapped = didOK
        
        super.init(nibName: nil, bundle: nil)
        
        // Display on top of the current screen without removing it from the hierarchy. This is what allows blur to correctly blur the background content.
        modalPresentationStyle = .overFullScreen
        
        // CrossDissolve smoothly fades the background. We animate the card itself manually in viewDidAppear.
        modalTransitionStyle = .crossDissolve
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        shadowContainerSetup()
        setupBlurView()
        setupContent()
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateAppearance()

    }
    
    // MARK: - Background
    
    private func setupBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
    }
    
    // MARK: - Shadow Container
    
    private func shadowContainerSetup() {
        
        view.addSubview(shadowContainer)
        
        shadowContainer.backgroundColor = .clear
        shadowContainer.layer.cornerRadius = 24
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOpacity = 0.22
        shadowContainer.layer.shadowRadius = 20
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        
        shadowContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(310)
             // The height is determined automatically by the content ✓
        }
        
    }

    // MARK: - Setup: Blur View

    private func setupBlurView() {
        shadowContainer.addSubview(blurView)

        blurView.layer.cornerRadius = 24

        // .continuous - Apple's smooth rounding type (iOS 13+)
        blurView.layer.cornerCurve  = .continuous
        // Required for cornerRadius to work on UIVisualEffectView
        blurView.clipsToBounds      = true

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Setup: Labels & Text Stack

    private func setupContent() {
      
        // Add all content to blurView.contentView — this is a UIKit requirement. Adding content directly to blurView will trigger a warning and display issues.
        let contentView = blurView.contentView

        titleLabel.text   = alertTitle
        messageLabel.text = alertMessage

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(messageLabel)

        contentView.addSubview(textStack)
        textStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Разделитель
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(textStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5) // тонкая линия, как у системного алерта
        }

        // buttonStackView добавляется в setupButtons()
        // и прикрепляется к separatorView снизу.
    }

    // MARK: - Setup: Buttons

    private func setupButtons() {
        let contentView = blurView.contentView

        let confirmButton = makeButton(title: confirm, style: .confirm)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(confirmButton)

        if let cancelTitle = cancel {
            let cancelButton = makeButton(title: cancelTitle, style: .cancel)
            cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
            // Кнопка отмены идёт первой слева — как у системного алерта
            buttonStack.insertArrangedSubview(cancelButton, at: 0)
        }

        contentView.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }

    // MARK: - Button Factory

    private enum ButtonStyle {
        case confirm // синий, акцентный
        case cancel  // серый, вторичный
    }

   
    // Factory method - creates a button with the desired style. Separately defined to avoid duplicating code for confirm and cancel.
    private func makeButton(title: String, style: ButtonStyle) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(
            ofSize: 15,
            weight: style == .confirm ? .semibold : .regular
        )

        switch style {
        case .confirm:
            // Системный синий — адаптируется к Dark Mode ✓
            button.setTitleColor(.systemBlue, for: .normal)
        case .cancel:
            button.setTitleColor(.secondaryLabel, for: .normal)
        }

        button.layer.cornerRadius  = 10
        button.layer.cornerCurve   = .continuous // iOS 13+ ✓
        button.backgroundColor     = UIColor.systemGray5 // почти прозрачный фон

        return button
    }

    // MARK: - Actions

    @objc private func confirmTapped() {
        // Сначала dismiss (с анимацией закрытия), потом — клоужер.
        // [weak self] разрывает retain cycle:
        // алерт → хранит onConfirm → onConfirm захватывает self → алерт
        dismiss(animated: true) { [weak self] in
            self?.didConfirmTapped?()
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            self?.didCancelTapped?()
        }
    }

    // MARK: - Animation

    private func animateAppearance() {
        // Устанавливаем начальное состояние: маленький и невидимый
        shadowContainer.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        shadowContainer.alpha     = 0

        // usingSpringWithDamping: 0.7 — лёгкий упругий отскок, не слишком резкий.
        // initialSpringVelocity: 0.5 — небольшая начальная скорость.
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                self.shadowContainer.transform = .identity // возврат к нормальному размеру
                self.shadowContainer.alpha     = 1
            },
            completion: nil
        )
    }
}



// Универсальный кастомный алерт в стиле Apple.
/// Поддерживает 1 или 2 кнопки, блюр-фон, анимацию появления.
///
/// Пример использования с одной кнопкой (токен протух):
///
///     let alert = CustomAlertVC(
///         title: "Сессия истекла",
///         message: "Пожалуйста, войдите в аккаунт заново.",
///         confirmTitle: "Войти"
///     )
///     alert.onConfirm = { [weak self] in
///         self?.navigateToLogin()
///     }
///     present(alert, animated: false)
///
/// Пример использования с двумя кнопками (рефанд):
///
///     let alert = CustomAlertVC(
///         title: "Запрос возврата",
///         message: "Вы уверены, что хотите вернуть средства за покупку?",
///         confirmTitle: "Да, вернуть",
///         cancelTitle: "Отмена"
///     )
///     alert.onConfirm = { [weak self] in
///         self?.requestRefund()
///     }
///     alert.onCancel = { [weak self] in
///         print("Пользователь отказался от рефанда")
///     }
///     present(alert, animated: false)
//
