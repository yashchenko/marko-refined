//
//  TeacherCollectionViewCell.swift
//  Marko
//
//  Created by Ivan on 06.09.2025.
//

import UIKit

class TeacherCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    // Static identifier for cell registration
    static let reuseIdentifier = "TeacherCollectionViewCell"
    
    // MARK: - UI Elements
    
    private let teacherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Placeholder color while image loads
        imageView.backgroundColor = .systemGray4
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // A horizontal stack view to group the star and rating
    private lazy var ratingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [starIconImageView, ratingLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        addSubviews()
        setupConstraints()
        applyTextShadows()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Setup Methods
    
    private func setupCell() {
        // Apply rounded corners to the cell's content view
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }
    
    private func addSubviews() {
        // Add subviews in rendering order (background first)
        contentView.addSubview(teacherImageView)
        
        // Add text elements on top of the image
        contentView.addSubview(priceLabel)
        contentView.addSubview(ratingStackView)
        contentView.addSubview(headlineLabel)
        contentView.addSubview(nameLabel)
    }
    
    private func setupConstraints() {
        // Using a padding constant for consistency
        let padding: CGFloat = 16.0
        
        NSLayoutConstraint.activate([
            // Teacher Image View fills the entire cell
            teacherImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            teacherImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            teacherImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            teacherImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Price Label in the bottom-right corner
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            // Rating Stack View (star + text) in the bottom-left corner
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            ratingStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            // Make sure the star icon size is controlled
            starIconImageView.heightAnchor.constraint(equalToConstant: 16),
            starIconImageView.widthAnchor.constraint(equalToConstant: 16),
            
            // Headline Label just above the rating
            headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            headlineLabel.bottomAnchor.constraint(equalTo: ratingStackView.topAnchor, constant: -6),
            headlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -padding),
            
            // Name Label just above the headline
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameLabel.bottomAnchor.constraint(equalTo: headlineLabel.topAnchor, constant: -6),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding)
        ])
    }
    
    private func applyTextShadows() {
        // This is the key to making the text readable on any background, as per the design
        let textElements = [nameLabel, headlineLabel, ratingLabel, priceLabel]
        for label in textElements {
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowRadius = 4.0
            label.layer.shadowOpacity = 0.8
            label.layer.shadowOffset = CGSize(width: 2, height: 2)
            label.layer.masksToBounds = false
        }
    }
    
    // MARK: - Public Configuration
    
    public func configure(with teacher: Teacher) {
        // In a future ticket, this is where we will use Kingfisher
        // For now, we can test with a local or system image
        // teacherImageView.image = UIImage(named: "somePlaceholder")
        
        nameLabel.text = teacher.name
        headlineLabel.text = teacher.headline
        ratingLabel.text = "\(teacher.rating) (\(teacher.reviewCount) reviews)"
        priceLabel.text = "$\(teacher.hourlyRate)/hr"
    }
    
    // It's good practice to reset content for cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        teacherImageView.image = nil
        nameLabel.text = nil
        headlineLabel.text = nil
        ratingLabel.text = nil
        priceLabel.text = nil
    }
}
