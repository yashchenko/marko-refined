//
//  ChatMessageCell.swift
//  Marko
//
//  Created by Ivan on 16.07.2026.
//

import UIKit


class ChatMessageCell: UITableViewCell {
    
    let cellIdentofier = "cellID"
    
    // MARK: - UI Elements
    
    var bubble: UIView = {
        let bubble = UIView()
        bubble.layer.cornerRadius = 16
        bubble.clipsToBounds = true
        return bubble
    }()
    
    var messageLabel: UILabel = {
       
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: ChatMessage, user: Bool) {
        
        if user {
            bubble.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            
            bubble.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(8)
                make.trailing.equalToSuperview().inset(16)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            }
            
            
        } else {
            
            
            
            
        }
        
        
        
        
    }
    
    
}


extension ChatMessageCell: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
