//
//  ChatMessageCell.swift
//  Marko
//
//  Created by Ivan on 16.07.2026.
//

import UIKit


class ChatMessageCell: UITableViewCell {
    
    static let cellIdentofier = "cellID"
    
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
        
        contentView.addSubview(bubble)
        bubble.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: ChatMessage, user: Bool) {
        
        messageLabel.text = message.text
        
        if user {
            bubble.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            
            bubble.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(8)
                make.trailing.equalToSuperview().inset(16)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            }
            
            
        } else {
            
            bubble.backgroundColor = .systemGray5
            messageLabel.textColor = .label
            
            bubble.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(8)
                make.leading.equalToSuperview().inset(16)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            }
        }
    }
}
