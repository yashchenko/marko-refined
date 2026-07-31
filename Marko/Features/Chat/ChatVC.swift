//
//  ChatVCswift.swift
//  Marko
//
//  Created by Ivan on 25.07.2026.
//

import UIKit
import SnapKit

class ChatVC: UIViewController {
    
    // MARK: - Properties
    
    private let vm: ChatVM
    
    // link to bottom constraint for keybord control
    private var inputBottomConstraint: Constraint?
    
    // MARK: - UI
    
    private lazy var table: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.allowsSelection = false
        table.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.cellIdentofier)
        table.dataSource = self
        
        // enabling automatic calculation of text bubble
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 60
        return table
    }()
    
    private let inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type a message..."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.handleSend()
        }), for: .touchUpInside)
        return button
    }()
    
    
    init(chatVM: ChatVM) {
        self.vm = chatVM
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupKeyboardObservers()
        bindVM()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        table.addGestureRecognizer(tap)
        
        vm.loadMessages()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        
        title = vm.chat.teacherName
        view.backgroundColor = .systemBackground
        
        view.addSubviews(views: [
            table,
            inputContainer
        ])
        
        inputContainer.addSubviews(views: [
        
            messageTextField,
            sendButton
        
        ])
        
        
        inputContainer.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            
            self.inputBottomConstraint = maker.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        
        messageTextField.snp.makeConstraints { maker in
            
            maker.top.bottom.equalToSuperview().inset(10)
            maker.leading.equalToSuperview().inset(16)
        }
        
        sendButton.snp.makeConstraints { maker in
            maker.centerY.equalTo(messageTextField)
            maker.leading.equalTo(messageTextField.snp.trailing).offset(12)
            maker.trailing.equalToSuperview().inset(16)
            maker.width.height.equalTo(30)
        }
        
        table.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(inputContainer.snp.top)
        }
    }
    
    func bindVM() {
        
        vm.didUpdateMessages = { [weak self] in
            
            guard let self = self else { return }
            
            self.table.reloadData()
            self.scrollToBottom(animated: true)
            
        }
        
        vm.didErrorOccur = { [weak self] someError in
            
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "Error", message: someError, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            
        }
        
    }
    
    
    // MARK: - Send message
    private func handleSend() {
        
        guard let text = messageTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        vm.sendMessage(text: text)
        messageTextField.text = ""
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    private func scrollToBottom(animated: Bool) {
        
        guard !vm.messages.isEmpty else { return }
        let indexPath = IndexPath(row: vm.messages.count - 1, section: 0)
        table.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        
    }
    
    // MARK: - Keyboard Management
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow (notification: NSNotification) {
        
        guard let keyboardFrane = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let safeAreaBottom = view.safeAreaInsets.bottom
        let keyboardHeight = keyboardFrane.height - safeAreaBottom
        
        inputBottomConstraint?.update(offset: -keyboardHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
        
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        inputBottomConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension ChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.cellIdentofier, for: indexPath) as? ChatMessageCell else { return UITableViewCell() }
        
        let message = vm.messages[indexPath.row]
        let isCurrentUser = message.senderID == vm.currentUserId
        
        cell.configure(message: message, user: isCurrentUser)
        
        return cell
    }
}
