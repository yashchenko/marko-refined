//
//  EmptyStateVC.swift
//  Marko
//
//  Created by Ivan on 30.05.2026.
//

import UIKit
import SnapKit

class EmptyState: UIView {
    

    // MARK: - Properties
    
    let imageEmpty: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    
    let mainLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    
    func setupUI() {
        
        addSubviews(views: [
        
            imageEmpty,
            mainLabel,
            subtitleLabel
        
        ])
        
        NSLayoutConstraint.activate([
            
            imageEmpty.heightAnchor.constraint(equalToConstant: 150),
            imageEmpty.widthAnchor.constraint(equalToConstant: 150),
            
            imageEmpty.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            imageEmpty.centerXAnchor.constraint(equalTo: centerXAnchor)
        
        ])
        
        NSLayoutConstraint.activate([
        
            mainLabel.topAnchor.constraint(equalTo: imageEmpty.bottomAnchor, constant: 10),
           
            mainLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            mainLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 20),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 100),
            subtitleLabel.widthAnchor.constraint(equalToConstant: 200)
        
        ])
        
       
    }
    
    func configure(image: String, mainLabel: String, subtitleLabel: String) {
                
        imageEmpty.image = UIImage(named: image)
        self.mainLabel.text = mainLabel
        self.subtitleLabel.text = subtitleLabel
        
    }
    
}
