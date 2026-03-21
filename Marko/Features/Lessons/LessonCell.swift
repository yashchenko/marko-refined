//
//  LessonCell.swift
//  Marko
//
//  Created by Ivan on 01.02.2026.
//

import UIKit
import SnapKit
import Kingfisher

class LessonCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "LessonCell"
    
    // MARK: - Date Formatter
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM, HH:mm"
        return f
    }()
    
    
    // MARK: - UI
    
    private let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = false // иначе тень не будет видна
        
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1 // легкая прозрачность
        container.layer.shadowOffset = CGSize(width: 0, height: 4) // тень снизу
        container.layer.shadowRadius = 8 // размытие тени
        
        return container
    }()
    
    // аватар учителя
    private let teacherAvatar: UIImageView = {
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.backgroundColor = .systemGray5
        avatar.layer.cornerRadius = 30  // Делаем круглым (размер установим в constraints)
        
        
        return avatar
    }()
    
    private let teacherNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        
        return label
    }()
    // Предмет/хедлайн (серый, чуть меньше)
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    // иконка календаря sf symbol
    private let calendarIconImageView: UIImageView = {
        let calendarIcon = UIImageView()
        calendarIcon.image = UIImage(systemName: "calendar")
        calendarIcon.tintColor = .systemBlue
        calendarIcon.contentMode = .scaleAspectFit
        return calendarIcon
    }()
    
    
    /// Дата и время урока
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    /// Бейдж статуса (Upcoming / Completed / Cancelled)
    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        
        // Паддинг внутри бейджа (через contentInsets не работает у UILabel, используем constraints)
        return label
    }()
    
    /// Кнопка "Join Lesson"
    private let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join Lesson", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        
        // Тень на кнопке (для "Lickable" эффекта)
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    func setupUI() {
        
        contentView.addSubview(containerView)
        
        containerView.addSubviews(views: [
            
            teacherAvatar,
            teacherNameLabel,
            subjectLabel,
            calendarIconImageView,
            dateTimeLabel,
            statusBadge,
            joinButton
            
            
        ])
    }
    
    func setupConstraints() {
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        teacherAvatar.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.size.equalTo(60)
        }
        
        teacherNameLabel.snp.makeConstraints { make in
            make.top.equalTo(teacherAvatar.snp.top).offset(4)
            make.leading.equalTo(teacherAvatar.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }
        
        
        subjectLabel.snp.makeConstraints { make in
            make.top.equalTo(teacherNameLabel.snp.bottom).offset(4)
            make.leading.equalTo(teacherNameLabel.snp.leading)
            make.trailing.equalTo(teacherNameLabel.snp.trailing)
        }
        
       
        calendarIconImageView.snp.makeConstraints { make in
            make.top.equalTo(teacherAvatar.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.size.equalTo(16)  // Маленькая иконка
        }
        
        // Текст даты (справа от иконки)
        dateTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(calendarIconImageView.snp.centerY)
            make.leading.equalTo(calendarIconImageView.snp.trailing).offset(6)
            make.trailing.lessThanOrEqualTo(statusBadge.snp.leading).offset(-8)
        }
        
      
        statusBadge.snp.makeConstraints { make in
            make.centerY.equalTo(dateTimeLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(80)  // Минимальная ширина
        }
       
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(dateTimeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(48)  // Удобная высота для кнопки
        }
    }
    
    func configure(lesson: Lesson) {
        
        if let url = URL(string: lesson.teacherProfileImageURL) {
            let placeholder = UIImage(systemName: "person.circle.fill")
            teacherAvatar.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.2)), .cacheOriginalImage])
        } else {
            
            teacherAvatar.image = UIImage(systemName: "person.circle.fill")
        }
        
        teacherNameLabel.text = lesson.teacherName
        subjectLabel.text = lesson.subject
        
        dateTimeLabel.text = formatDateTime(lesson.startTime)
        
        configureStatusBadge(for: lesson.status)
        
        configureJoinButton(for: lesson)
    }
    
    // MARK: - Helpers
    
    private func formatDateTime(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }
    
    private func configureStatusBadge(for status: LessonStatus) {
        
        switch status {
        case .upcoming:
            statusBadge.text = "Upcoming"
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusBadge.textColor = .systemGreen
            
        case .completed:
            statusBadge.text = "Completed"
            statusBadge.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
            statusBadge.textColor = .gray
            
        case .cancelledByStudent, .cancelledByTeacher:
            
            statusBadge.text = "Cancelled"
            statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            statusBadge.textColor = .systemRed
            
        }
    }
    
    private func configureJoinButton(for lesson: Lesson) {
//
//        let now = Date()
//
//        let startSoon = lesson.startTime.timeIntervalSince(now) < 300
        
        let now = Date()
        
        let secondsFromStart = lesson.startTime.timeIntervalSince(now)
        
        let canJoin = secondsFromStart <= 300 && secondsFromStart >= -300
        
        switch lesson.status {
        case .upcoming:
            
            if canJoin {
                
                joinButton.isEnabled = true
                joinButton.alpha = 1.0
                joinButton.setTitle("Join Lesson", for: .normal)
                joinButton.backgroundColor = .systemGreen
            } else {
                
                joinButton.isEnabled = false
                joinButton.alpha = 0.5
                joinButton.setTitle("Starts soon", for: .normal)
                joinButton.backgroundColor = .systemGray
            }
            
        case .completed:
            
            joinButton.isEnabled = false
            joinButton.alpha = 0.5
            joinButton.setTitle("Finished", for: .normal)
            joinButton.backgroundColor = .systemGray
            
        case .cancelledByTeacher, .cancelledByStudent:
            joinButton.isEnabled = false
            joinButton.alpha = 0.5
            joinButton.setTitle("Cancelled", for: .normal)
            joinButton.backgroundColor = .systemRed
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        teacherAvatar.kf.cancelDownloadTask()
        teacherAvatar.image = nil
        
        teacherNameLabel.text = nil
        subjectLabel.text = nil
        dateTimeLabel.text = nil
        statusBadge.text = nil
        
        joinButton.isEnabled = true
        joinButton.alpha = 1.0
        joinButton.backgroundColor = .systemBlue
        joinButton.setTitle("Join Lesson", for: .normal)
    }
}
