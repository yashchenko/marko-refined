//
//  PrivacyPolicy.swift
//  Marko
//
//  Created by Ivan on 18.04.2026.
//

import UIKit
import SnapKit

class PrivacyPolicyVC: UIViewController {
    
    let textPrivacyPolicy = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean fermentum elit ut placerat consectetur. Nam porttitor molestie justo. Nam eleifend diam vitae tortor ultricies, quis volutpat purus gravida. Ut mi nulla, dapibus cursus mattis eu, suscipit sit amet nisl. Proin sollicitudin in lorem vitae feugiat. Nunc placerat turpis at euismod sagittis. Nunc non aliquet purus. Nullam sit amet ultricies lacus, sed congue arcu. Proin vel auctor augue. Nam pulvinar sem a sem malesuada, nec pellentesque tellus placerat. Nulla mollis, lorem ut lacinia luctus, nulla augue commodo libero, in mattis nisl lacus eu felis. Suspendisse in sapien luctus, imperdiet justo at, posuere nibh. Aenean suscipit neque at est cursus, ac pellentesque erat rutrum. Praesent a euismod sem, eget volutpat odio. Cras at tincidunt risus, tincidunt aliquet nunc. Sed accumsan interdum purus, ac facilisis lectus euismod eu. Suspendisse sed ipsum sed metus porta congue. Vestibulum turpis lacus, semper at purus id, eleifend vulputate elit. Vestibulum condimentum sed sem sed ultricies. Donec ac euismod arcu, eu consequat elit. Vestibulum posuere augue eu dolor suscipit vehicula. Vivamus mollis ornare quam eu pulvinar. Praesent vulputate sem ut augue varius, id tempus felis placerat. Pellentesque maximus ac arcu eu convallis. Nulla a auctor metus, a aliquam tortor.Donec faucibus, quam a eleifend lobortis, turpis turpis faucibus urna, sit amet condimentum ipsum quam at dolor. Sed vestibulum vestibulum magna nec convallis. Pellentesque tincidunt, tortor et aliquet fermentum, ante massa cursus turpis, id congue ex lectus sed metus. Nulla auctor mauris at placerat vestibulum. Cras euismod commodo mauris vitae ullamcorper. Praesent blandit molestie sem non pellentesque. Morbi a pretium augue. Vestibulum maximus aliquet erat. Pellentesque egestas venenatis diam ut molestie. Phasellus erat tellus, malesuada sed nulla vel, vehicula convallis purus. In lobortis massa vel lectus vestibulum, non feugiat neque feugiat. Suspendisse dapibus efficitur sapien non varius. Integer vitae sapien ultrices, maximus risus ut, ultricies sapien. Vivamus rutrum consequat tempor. Fusce finibus rhoncus lectus, sed iaculis tellus congue eget. Sed rhoncus vitae arcu in aliquet. Sed pharetra, ante sit amet tristique malesuada, diam est commodo mi, in egestas tellus purus et dolor. Etiam id neque purus. Integer auctor urna vitae tortor ultrices placerat. Donec vitae risus lorem. Fusce eget felis risus. Quisque porta, purus et egestas efficitur, justo tortor vehicula nunc, nec iaculis risus elit id tellus. Mauris nec ligula elit. Morbi malesuada metus orci, et sagittis elit bibendum at. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent vestibulum metus lectus, sed dictum ligula viverra ut. Vivamus sit amet nulla vitae neque porta facilisis. Sed ac pulvinar dolor, vel facilisis justo. Aenean dapibus porttitor faucibus. Pellentesque a tellus eu dui sodales vulputate quis ut mi. Aliquam quis dui nisi. Etiam ante lacus, tempus vel consequat ac, tempus id nunc."
    
    var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    var contentView = UIView()
    
    lazy var privacyPolicy: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = textTermsOfService
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        
        let padding: CGFloat = 20
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(termsLabel)
                
        [scrollView, contentView, termsLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        contentView.backgroundColor = .systemOrange
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide)
            make.leading.equalTo(scrollView.contentLayoutGuide)
            make.trailing.equalTo(scrollView.contentLayoutGuide)
            make.bottom.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        termsLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.edges).inset(padding)
        }
    }
}
