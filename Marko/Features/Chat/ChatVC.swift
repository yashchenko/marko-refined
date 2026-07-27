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
    
    let vm: ChatVM
    
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
    
    private func handleSend() {
        
        
    }
    
}


extension ChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    
    
}
